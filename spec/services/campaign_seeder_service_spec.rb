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
  
  # Master Campaign for non-template character copying
  let!(:master_campaign) do
    Campaign.create!(
      name: 'Master Campaign',
      user: gamemaster
    )
  end
  
  let!(:master_npc) do
    Character.create!(
      name: 'Master NPC Boss',
      is_template: false,
      action_values: { "Type" => "Boss" },
      campaign: master_campaign,
      user: gamemaster
    )
  end
  
  let!(:master_featured_foe) do
    Character.create!(
      name: 'Master Featured Foe',
      is_template: false,
      action_values: { "Type" => "Featured Foe" },
      campaign: master_campaign,
      user: gamemaster
    )
  end
  
  let!(:master_template_char) do
    Character.create!(
      name: 'Should Not Be Copied',
      is_template: true,
      campaign: master_campaign,
      user: gamemaster
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
        }.to change { new_campaign.characters.count }.by(3) # 1 template + 2 from Master Campaign
      end

      it 'marks the campaign as seeded' do
        expect(new_campaign.seeded_at).to be_nil
        
        CampaignSeederService.seed_campaign(new_campaign)
        new_campaign.reload
        
        expect(new_campaign.seeded_at).to be_present
      end

      it 'duplicates template character attributes correctly' do
        CampaignSeederService.seed_campaign(new_campaign)
        
        # Find the template character specifically
        duplicated_character = new_campaign.characters.find { |c| c.name.include?('Martial Artist Template') }
        expect(duplicated_character).not_to be_nil
        expect(duplicated_character.is_template).to be true
        expect(duplicated_character.campaign).to eq(new_campaign)
      end

      it 'returns true on success' do
        result = CampaignSeederService.seed_campaign(new_campaign)
        expect(result).to be true
      end
      
      context 'with Master Campaign present' do
        it 'copies non-template characters from Master Campaign' do
          CampaignSeederService.seed_campaign(new_campaign)
          
          character_names = new_campaign.characters.map(&:name)
          expect(character_names).to include('Master NPC Boss')
          expect(character_names).to include('Master Featured Foe')
        end
        
        it 'does not copy template characters from Master Campaign' do
          CampaignSeederService.seed_campaign(new_campaign)
          
          character_names = new_campaign.characters.map(&:name)
          expect(character_names).not_to include('Should Not Be Copied')
        end
        
        it 'copies both master template and Master Campaign characters' do
          expect {
            CampaignSeederService.seed_campaign(new_campaign)
          }.to change { new_campaign.characters.count }.by(3)
          # 1 from master template + 2 non-template from Master Campaign
        end
        
        it 'preserves character types when copying from Master Campaign' do
          CampaignSeederService.seed_campaign(new_campaign)
          
          boss = new_campaign.characters.find_by(name: 'Master NPC Boss')
          foe = new_campaign.characters.find_by(name: 'Master Featured Foe')
          
          expect(boss.action_values["Type"]).to eq('Boss')
          expect(foe.action_values["Type"]).to eq('Featured Foe')
        end
      end
      
      context 'when Master Campaign does not exist' do
        before do
          master_npc.destroy
          master_featured_foe.destroy
          master_template_char.destroy
          master_campaign.destroy
        end
        
        it 'still seeds with template characters' do
          expect {
            CampaignSeederService.seed_campaign(new_campaign)
          }.to change { new_campaign.characters.count }.by(1)
        end
        
        it 'logs warning about missing Master Campaign' do
          allow(Rails.logger).to receive(:info)
          expect(Rails.logger).to receive(:info).with("No Master Campaign found, skipping non-template character copying")
          CampaignSeederService.seed_campaign(new_campaign)
        end
      end
      
      context 'when character duplication fails' do
        before do
          # Allow template character duplication to work normally
          allow(CharacterDuplicatorService).to receive(:duplicate_character)
            .with(template_character, gamemaster, new_campaign)
            .and_call_original
          # Stub failure for master_npc
          allow(CharacterDuplicatorService).to receive(:duplicate_character)
            .with(master_npc, gamemaster, new_campaign)
            .and_return(double(save: false, errors: double(full_messages: ['Validation failed'])))
          # Allow master_featured_foe to work normally
          allow(CharacterDuplicatorService).to receive(:duplicate_character)
            .with(master_featured_foe, gamemaster, new_campaign)
            .and_call_original
        end
        
        it 'continues copying other characters' do
          allow(Rails.logger).to receive(:error)
          allow(Rails.logger).to receive(:info)
          
          expect {
            CampaignSeederService.seed_campaign(new_campaign)
          }.to change { new_campaign.characters.count }.by(2)
          # Should copy: 1 template + 1 successful non-template (featured foe)
        end
        
        it 'logs error for failed character' do
          allow(Rails.logger).to receive(:info)
          expect(Rails.logger).to receive(:error).with(/Failed to copy character Master NPC Boss from Master Campaign: Validation failed/)
          
          CampaignSeederService.seed_campaign(new_campaign)
        end
        
        it 'still returns true if template seeding succeeded' do
          allow(Rails.logger).to receive(:error)
          allow(Rails.logger).to receive(:info)
          
          result = CampaignSeederService.seed_campaign(new_campaign)
          expect(result).to be true
        end
      end
      
      context 'when character duplication raises exception' do
        before do
          # Allow template character duplication to work normally
          allow(CharacterDuplicatorService).to receive(:duplicate_character)
            .with(template_character, gamemaster, new_campaign)
            .and_call_original
          # Raise exception for master_npc
          allow(CharacterDuplicatorService).to receive(:duplicate_character)
            .with(master_npc, gamemaster, new_campaign)
            .and_raise(StandardError, 'Database connection error')
          # Allow master_featured_foe to work normally
          allow(CharacterDuplicatorService).to receive(:duplicate_character)
            .with(master_featured_foe, gamemaster, new_campaign)
            .and_call_original
        end
        
        it 'catches exception and continues with other characters' do
          allow(Rails.logger).to receive(:error)
          allow(Rails.logger).to receive(:info)
          
          expect {
            CampaignSeederService.seed_campaign(new_campaign)
          }.to change { new_campaign.characters.count }.by(2)
          # Should copy: 1 template + 1 successful non-template (featured foe)
        end
        
        it 'logs exception details' do
          allow(Rails.logger).to receive(:info)
          expect(Rails.logger).to receive(:error).with(/Error copying character Master NPC Boss from Master Campaign: Database connection error/)
          
          CampaignSeederService.seed_campaign(new_campaign)
        end
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
        }.to change { target_campaign.characters.count }.by(3) # 1 from source + 2 from Master Campaign
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
        
        # Find the source character specifically (not Master Campaign characters)
        copied_character = target_campaign.characters.find { |c| c.name.include?('Source Character') }
        expect(copied_character).not_to be_nil
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

      it 'still returns true but copies Master Campaign characters' do
        expect {
          result = CampaignSeederService.copy_campaign_content(empty_campaign, target_campaign)
          expect(result).to be true
        }.to change { target_campaign.characters.count }.by(2) # Only Master Campaign characters
      end
    end
    
    context 'when entities have image positions' do
      before do
        # Add image positions to source entities
        ImagePosition.create!(
          positionable: source_character,
          context: 'desktop_index',
          x_position: 100.5,
          y_position: 200.5,
          style_overrides: { color: 'red' }
        )
        
        ImagePosition.create!(
          positionable: source_character,
          context: 'mobile_index',
          x_position: 50.0,
          y_position: 75.0,
          style_overrides: { size: 'small' }
        )
        
        ImagePosition.create!(
          positionable: source_vehicle,
          context: 'desktop_entity',
          x_position: 300.0,
          y_position: 400.0,
          style_overrides: { border: 'thick' }
        )
        
        ImagePosition.create!(
          positionable: source_faction,
          context: 'desktop_index',
          x_position: 150.0,
          y_position: 250.0,
          style_overrides: {}
        )
      end
      
      it 'copies image positions for characters' do
        CampaignSeederService.copy_campaign_content(source_campaign, target_campaign)
        
        copied_character = target_campaign.characters.find_by(name: 'Source Character')
        expect(copied_character.image_positions.count).to eq(2)
        
        desktop_position = copied_character.image_positions.find_by(context: 'desktop_index')
        expect(desktop_position.x_position).to eq(100.5)
        expect(desktop_position.y_position).to eq(200.5)
        expect(desktop_position.style_overrides).to eq({ 'color' => 'red' })
        
        mobile_position = copied_character.image_positions.find_by(context: 'mobile_index')
        expect(mobile_position.x_position).to eq(50.0)
        expect(mobile_position.y_position).to eq(75.0)
        expect(mobile_position.style_overrides).to eq({ 'size' => 'small' })
      end
      
      it 'copies image positions for vehicles' do
        CampaignSeederService.copy_campaign_content(source_campaign, target_campaign)
        
        copied_vehicle = target_campaign.vehicles.first
        expect(copied_vehicle.image_positions.count).to eq(1)
        
        position = copied_vehicle.image_positions.find_by(context: 'desktop_entity')
        expect(position.x_position).to eq(300.0)
        expect(position.y_position).to eq(400.0)
        expect(position.style_overrides).to eq({ 'border' => 'thick' })
      end
      
      it 'copies image positions for factions' do
        CampaignSeederService.copy_campaign_content(source_campaign, target_campaign)
        
        copied_faction = target_campaign.factions.first
        expect(copied_faction.image_positions.count).to eq(1)
        
        position = copied_faction.image_positions.find_by(context: 'desktop_index')
        expect(position.x_position).to eq(150.0)
        expect(position.y_position).to eq(250.0)
        expect(position.style_overrides).to eq({})
      end
      
      it 'handles entities without image positions gracefully' do
        # source_schtick has no image positions
        expect {
          CampaignSeederService.copy_campaign_content(source_campaign, target_campaign)
        }.not_to raise_error
        
        copied_schtick = target_campaign.schticks.first
        expect(copied_schtick.image_positions.count).to eq(0)
      end
      
      it 'copies image positions for the campaign itself' do
        # Add image positions to source campaign
        ImagePosition.create!(
          positionable: source_campaign,
          context: 'desktop_index',
          x_position: 500.0,
          y_position: 600.0,
          style_overrides: { theme: 'dark' }
        )
        
        CampaignSeederService.copy_campaign_content(source_campaign, target_campaign)
        
        expect(target_campaign.image_positions.count).to eq(1)
        position = target_campaign.image_positions.find_by(context: 'desktop_index')
        expect(position.x_position).to eq(500.0)
        expect(position.y_position).to eq(600.0)
        expect(position.style_overrides).to eq({ 'theme' => 'dark' })
      end
    end
  end
end