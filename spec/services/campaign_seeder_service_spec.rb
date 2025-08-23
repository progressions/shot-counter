require 'rails_helper'

RSpec.describe CampaignSeederService, type: :service do
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
      name: 'Martial Artist Template',
      is_template: true,
      campaign: master_template
    )
  end
  
  let(:new_campaign) { Campaign.create!(name: 'New Campaign', user: gamemaster) }

  describe '.seed_campaign' do
    context 'with a valid new campaign' do
      it 'seeds the campaign with template characters' do
        expect {
          CampaignSeederService.seed_campaign(new_campaign)
        }.to change { new_campaign.characters.count }.by(1)
      end

      it 'marks the campaign as seeded' do
        expect(new_campaign.seeded_at).to be_nil
        
        CampaignSeederService.seed_campaign(new_campaign)
        new_campaign.reload
        
        expect(new_campaign.seeded_at).to be_present
      end

      it 'duplicates template character attributes correctly' do
        CampaignSeederService.seed_campaign(new_campaign)
        
        duplicated_character = new_campaign.characters.first
        expect(duplicated_character.name).to eq('Martial Artist Template (1)')  # Name gets incremented for uniqueness
        expect(duplicated_character.is_template).to be true
        expect(duplicated_character.campaign).to eq(new_campaign)
      end

      it 'returns true on success' do
        result = CampaignSeederService.seed_campaign(new_campaign)
        expect(result).to be true
      end
    end

    context 'with an already seeded campaign' do
      before { new_campaign.update!(seeded_at: 1.hour.ago) }

      it 'does not seed again' do
        expect {
          CampaignSeederService.seed_campaign(new_campaign)
        }.not_to change { new_campaign.characters.count }
      end

      it 'returns false' do
        result = CampaignSeederService.seed_campaign(new_campaign)
        expect(result).to be false
      end
    end

    context 'when no master template exists' do
      before { 
        template_character.destroy
        master_template.destroy 
      }

      it 'returns false' do
        result = CampaignSeederService.seed_campaign(new_campaign)
        expect(result).to be false
      end

      it 'does not mark campaign as seeded' do
        CampaignSeederService.seed_campaign(new_campaign)
        new_campaign.reload
        
        expect(new_campaign.seeded_at).to be_nil
      end
    end

    context 'with an unsaved campaign' do
      let(:unsaved_campaign) { Campaign.new(name: 'Unsaved Campaign', user: gamemaster) }

      it 'returns false' do
        result = CampaignSeederService.seed_campaign(unsaved_campaign)
        expect(result).to be false
      end
    end
  end
end