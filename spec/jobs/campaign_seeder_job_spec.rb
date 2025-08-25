require 'rails_helper'

RSpec.describe CampaignSeederJob, type: :job do
  let!(:gamemaster) do
    User.create!(
      email: 'gamemaster@example.com',
      first_name: 'Game',
      last_name: 'Master',
      password: 'TestPass123!',
      gamemaster: true
    )
  end
  
  let!(:master_template) do
    Campaign.create!(
      name: 'Master Template Campaign',
      is_master_template: true,
      user: gamemaster
    )
  end
  
  let!(:template_character) do
    Character.create!(
      name: 'Test Template',
      is_template: true,
      campaign: master_template
    )
  end
  
  let(:campaign) { Campaign.create!(name: 'Test Campaign', user: gamemaster) }

  describe '#perform' do
    context 'with a valid campaign' do
      it 'calls CampaignSeederService.seed_campaign' do
        expect(CampaignSeederService).to receive(:seed_campaign).with(campaign).and_return(true)
        
        described_class.perform_now(campaign.id)
      end

      it 'returns true on success' do
        # Skip the after_create callback to test the job directly
        fresh_campaign = Campaign.new(name: 'Fresh Test Campaign', user: gamemaster)
        fresh_campaign.save!(validate: false)
        fresh_campaign.update_column(:seeded_at, nil) # Ensure it's not seeded
        
        result = described_class.perform_now(fresh_campaign.id)
        expect(result).to be true
      end

      it 'seeds the campaign with template data' do
        # Skip the after_create callback to test the job directly
        fresh_campaign = Campaign.new(name: 'Another Test Campaign', user: gamemaster)
        fresh_campaign.save!(validate: false)
        fresh_campaign.update_column(:seeded_at, nil) # Ensure it's not seeded
        
        expect {
          described_class.perform_now(fresh_campaign.id)
          fresh_campaign.reload
        }.to change { fresh_campaign.characters.count }.by_at_least(1)
      end
    end

    context 'with non-existent campaign' do
      it 'handles missing campaign gracefully' do
        result = described_class.perform_now('nonexistent-id')
        expect(result).to be false
      end

      it 'logs error for missing campaign' do
        expect(Rails.logger).to receive(:error).with(/Campaign seeding job failed - campaign not found/)
        
        described_class.perform_now('nonexistent-id')
      end
    end

    context 'when seeding fails' do
      before do
        allow(CampaignSeederService).to receive(:seed_campaign).and_return(false)
      end

      it 'returns false on failure' do
        result = described_class.perform_now(campaign.id)
        expect(result).to be false
      end

      it 'logs error on failure' do
        expect(Rails.logger).to receive(:error).with(/Campaign seeding job failed for campaign/).at_least(:once)
        
        described_class.perform_now(campaign.id)
      end
    end
  end
end