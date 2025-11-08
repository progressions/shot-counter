require 'rails_helper'
require 'stringio'
require 'uri'

RSpec.describe CampaignImageCopyService, type: :service do
  let(:user) do
    User.create!(
      email: 'owner@example.com',
      first_name: 'Owner',
      last_name: 'User',
      password: 'Password123!'
    )
  end

  let!(:source_campaign) do
    Campaign.create!(
      name: 'Master Template',
      is_master_template: true,
      user: user
    )
  end

  let!(:target_campaign) do
    Campaign.create!(
      name: 'Target Campaign',
      user: user
    )
  end

  let!(:source_schtick) do
    schtick = Schtick.create!(
      campaign: source_campaign,
      name: 'Shadow Fist',
      category: 'Guns'
    )
    schtick.update_column(:image_url, 'https://example.com/schticks/shadow_fist.png')
    schtick
  end

  let!(:target_schtick) do
    Schtick.create!(
      campaign: target_campaign,
      name: 'Shadow Fist',
      category: 'Guns'
    )
  end

  let!(:source_weapon) do
    weapon = Weapon.create!(
      campaign: source_campaign,
      name: 'Dragon Pistol',
      damage: 10
    )
    weapon.update_column(:image_url, 'https://example.com/weapons/dragon_pistol.png')
    weapon
  end

  let!(:target_weapon) do
    Weapon.create!(
      campaign: target_campaign,
      name: 'Dragon Pistol',
      damage: 10
    )
  end

  let(:stub_importer) do
    Class.new do
      def self.call(source_url:, attachable:, attachment_name: :image, **)
        attachable.public_send(attachment_name).attach(
          io: StringIO.new("fake image data for #{source_url}"),
          filename: File.basename(URI.parse(source_url).path.presence || 'image.jpg'),
          content_type: 'image/png'
        )
      end
    end
  end

  describe '#call' do
    it 'copies schtick and weapon images onto matching records' do
      result = described_class.new(
        target_campaign: target_campaign,
        source_campaign: source_campaign,
        importer: stub_importer
      ).call

      expect(result[:schticks].copied).to eq(1)
      expect(result[:weapons].copied).to eq(1)
      expect(target_schtick.reload.image).to be_attached
      expect(target_weapon.reload.image).to be_attached
    end

    it 'derives the source campaign from the master template flag when omitted' do
      result = described_class.call(
        target_campaign: target_campaign,
        importer: stub_importer
      )

      expect(result[:schticks].copied).to eq(1)
      expect(target_schtick.reload.image).to be_attached
    end

    it 'tracks missing targets and skipped sources without image URLs' do
      extra_source = Schtick.create!(
        campaign: source_campaign,
        name: 'Unmatched',
        category: 'Guns'
      )
      extra_source.update_column(:image_url, 'https://example.com/missing.png')
      Schtick.create!(
        campaign: source_campaign,
        name: 'No Image',
        category: 'Guns'
      )

      result = described_class.new(
        target_campaign: target_campaign,
        source_campaign: source_campaign,
        importer: stub_importer
      ).call

      expect(result[:schticks].missing).to eq(1)
      expect(result[:schticks].skipped).to eq(1) # missing image_url
    end

    it 'falls back to the image_url method when the column is blank' do
      source_schtick.update_column(:image_url, nil)
      allow_any_instance_of(Schtick)
        .to receive(:image_url)
        .and_return('https://example.com/schticks/from_method.png')

      result = described_class.new(
        target_campaign: target_campaign,
        source_campaign: source_campaign,
        importer: stub_importer
      ).call

      expect(result[:schticks].copied).to eq(1)
      expect(target_schtick.reload.image).to be_attached
    end

    it 'skips targets that already have an image unless force is true' do
      target_weapon.image.attach(
        io: StringIO.new('existing image'),
        filename: 'existing.png',
        content_type: 'image/png'
      )

      result = described_class.new(
        target_campaign: target_campaign,
        source_campaign: source_campaign,
        importer: stub_importer
      ).call

      expect(result[:weapons].skipped).to eq(1)

      described_class.new(
        target_campaign: target_campaign,
        source_campaign: source_campaign,
        importer: stub_importer,
        force: true
      ).call

      expect(target_weapon.reload.image.blob.filename.to_s).to eq('dragon_pistol.png')
    end

    it 'collects errors when the importer raises' do
      failing_importer = Class.new do
        def self.call(*)
          raise ImageKitImporter::DownloadError, 'boom'
        end
      end

      result = described_class.new(
        target_campaign: target_campaign,
        source_campaign: source_campaign,
        importer: failing_importer
      ).call

      expect(result[:schticks].errors).not_to be_empty
      expect(target_schtick.reload.image).not_to be_attached
    end
  end

  describe '.call' do
    it 'raises when no master template campaign is available' do
      source_campaign.update!(is_master_template: false)

      expect {
        described_class.call(target_campaign: target_campaign, importer: stub_importer)
      }.to raise_error(ArgumentError, /source_campaign/)
    end
  end
end
