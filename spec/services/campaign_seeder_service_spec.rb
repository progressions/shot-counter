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
      campaign: master_template,
      user: gamemaster
    )
  end
  
  let!(:source_campaign) do
    Campaign.create!(
      name: 'Source Campaign',
      user: gamemaster
    )
  end
  
  let!(:source_character) do
    Character.create!(
      name: 'Source Character',
      is_template: true,
      campaign: source_campaign,
      user: gamemaster
    )
  end
  
  let!(:source_vehicle) do
    Vehicle.create!(
      name: 'Source Vehicle',
      campaign: source_campaign,
      user: gamemaster
    )
  end
  
  let!(:source_schtick) do
    Schtick.create!(
      name: 'Source Schtick',
      category: 'Guns',
      campaign: source_campaign
    )
  end
  
  let!(:source_weapon) do
    Weapon.create!(
      name: 'Source Weapon',
      damage: 10,
      campaign: source_campaign
    )
  end
  
  let!(:source_juncture) do
    Juncture.create!(
      name: 'Source Juncture',
      campaign: source_campaign
    )
  end
  
  let!(:source_faction) do
    Faction.create!(
      name: 'Source Faction',
      campaign: source_campaign
    )
  end
  
  let(:new_campaign) do
    Campaign.create!(name: 'New Campaign', user: gamemaster)
  end

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
        expect(duplicated_character.name).to include('Martial Artist Template')
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

  describe '.copy_campaign_content' do
    let(:target_campaign) do
      Campaign.create!(name: 'Target Campaign', user: gamemaster)
    end

    context 'with valid campaigns' do
      it 'copies all content types from source to target campaign' do
        expect {
          CampaignSeederService.copy_campaign_content(source_campaign, target_campaign)
        }.to change { target_campaign.characters.count }.by(1)
         .and change { target_campaign.vehicles.count }.by(1)
         .and change { target_campaign.schticks.count }.by(1)
         .and change { target_campaign.weapons.count }.by(1)
         .and change { target_campaign.junctures.count }.by(1)
         .and change { target_campaign.factions.count }.by(1)
      end

      it 'returns true on success' do
        result = CampaignSeederService.copy_campaign_content(source_campaign, target_campaign)
        expect(result).to be true
      end

      it 'marks target campaign as seeded if not already seeded' do
        expect(target_campaign.seeded_at).to be_nil
        
        CampaignSeederService.copy_campaign_content(source_campaign, target_campaign)
        target_campaign.reload
        
        expect(target_campaign.seeded_at).to be_present
      end

      it 'does not overwrite existing seeded_at timestamp' do
        original_time = 2.hours.ago
        target_campaign.update!(seeded_at: original_time)
        
        CampaignSeederService.copy_campaign_content(source_campaign, target_campaign)
        target_campaign.reload
        
        expect(target_campaign.seeded_at).to be_within(1.second).of(original_time)
      end

      it 'copies character with correct attributes' do
        CampaignSeederService.copy_campaign_content(source_campaign, target_campaign)
        
        copied_character = target_campaign.characters.first
        expect(copied_character.name).to include('Source Character')
        expect(copied_character.campaign).to eq(target_campaign)
        expect(copied_character.user).to eq(gamemaster)
      end

      it 'copies vehicle with correct attributes' do
        CampaignSeederService.copy_campaign_content(source_campaign, target_campaign)
        
        copied_vehicle = target_campaign.vehicles.first
        expect(copied_vehicle.name).to include('Source Vehicle')
        expect(copied_vehicle.campaign).to eq(target_campaign)
        expect(copied_vehicle.user).to eq(gamemaster)
      end

      it 'copies other content with correct campaign association' do
        CampaignSeederService.copy_campaign_content(source_campaign, target_campaign)
        
        expect(target_campaign.schticks.first.name).to include('Source Schtick')
        expect(target_campaign.weapons.first.name).to include('Source Weapon')
        expect(target_campaign.junctures.first.name).to include('Source Juncture')
        expect(target_campaign.factions.first.name).to include('Source Faction')
      end
    end

    context 'with invalid campaigns' do
      let(:unsaved_campaign) { Campaign.new(name: 'Unsaved Campaign', user: gamemaster) }

      it 'returns false if source campaign is not persisted' do
        result = CampaignSeederService.copy_campaign_content(unsaved_campaign, target_campaign)
        expect(result).to be false
      end

      it 'returns false if target campaign is not persisted' do
        result = CampaignSeederService.copy_campaign_content(source_campaign, unsaved_campaign)
        expect(result).to be false
      end
    end

    context 'when source campaign has no content' do
      let(:empty_campaign) do
        Campaign.create!(name: 'Empty Campaign', user: gamemaster)
      end

      it 'still returns true but copies nothing' do
        expect {
          result = CampaignSeederService.copy_campaign_content(empty_campaign, target_campaign)
          expect(result).to be true
        }.not_to change { target_campaign.characters.count + target_campaign.vehicles.count }
      end
    end
  end
end