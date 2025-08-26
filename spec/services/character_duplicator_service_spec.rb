require 'rails_helper'

RSpec.describe CharacterDuplicatorService, type: :service do
  let!(:gamemaster) do
    User.create!(
      email: 'gamemaster@example.com',
      first_name: 'Game',
      last_name: 'Master',
      password: 'TestPass123!',
      gamemaster: true
    )
  end
  
  let!(:source_campaign) do
    Campaign.create!(
      name: 'Source Campaign',
      user: gamemaster
    )
  end
  
  let!(:target_campaign) do
    Campaign.create!(
      name: 'Target Campaign',
      user: gamemaster
    )
  end
  
  let!(:source_character) do
    Character.create!(
      name: 'Test Character',
      campaign: source_campaign,
      user: gamemaster,
      action_values: { 'Type' => 'PC', 'Defense' => 10, 'Toughness' => 8 }
    )
  end
  
  describe '.duplicate_character' do
    it 'creates a new character with same attributes' do
      duplicated = CharacterDuplicatorService.duplicate_character(source_character, gamemaster, target_campaign)
      
      expect(duplicated).to be_a(Character)
      expect(duplicated.name).to eq('Test Character')
      expect(duplicated.campaign).to eq(target_campaign)
      expect(duplicated.user).to eq(gamemaster)
      expect(duplicated.action_values['Type']).to eq('PC')
      expect(duplicated.action_values['Defense']).to eq(10)
      expect(duplicated.action_values['Toughness']).to eq(8)
    end
    
    it 'handles duplicate names with numbering' do
      # Create a character with the same name in target campaign
      Character.create!(
        name: 'Test Character',
        campaign: target_campaign,
        user: gamemaster
      )
      
      duplicated = CharacterDuplicatorService.duplicate_character(source_character, gamemaster, target_campaign)
      
      expect(duplicated.name).to eq('Test Character (1)')
    end
    
    context 'with image positions' do
      before do
        ImagePosition.create!(
          positionable: source_character,
          context: 'desktop_index',
          x_position: 100.0,
          y_position: 200.0,
          style_overrides: { color: 'blue' }
        )
        
        ImagePosition.create!(
          positionable: source_character,
          context: 'mobile_index',
          x_position: 50.0,
          y_position: 75.0,
          style_overrides: { size: 'large' }
        )
      end
      
      it 'copies image positions when apply_associations is called' do
        duplicated = CharacterDuplicatorService.duplicate_character(source_character, gamemaster, target_campaign)
        duplicated.save!
        
        # Image positions should not be copied yet
        expect(duplicated.image_positions.count).to eq(0)
        
        # Now apply associations which should copy image positions
        CharacterDuplicatorService.apply_associations(duplicated)
        
        expect(duplicated.image_positions.count).to eq(2)
        
        desktop_position = duplicated.image_positions.find_by(context: 'desktop_index')
        expect(desktop_position.x_position).to eq(100.0)
        expect(desktop_position.y_position).to eq(200.0)
        expect(desktop_position.style_overrides).to eq({ 'color' => 'blue' })
        
        mobile_position = duplicated.image_positions.find_by(context: 'mobile_index')
        expect(mobile_position.x_position).to eq(50.0)
        expect(mobile_position.y_position).to eq(75.0)
        expect(mobile_position.style_overrides).to eq({ 'size' => 'large' })
      end
    end
    
    context 'with schticks and weapons' do
      let!(:source_schtick) do
        Schtick.create!(
          name: 'Test Schtick',
          campaign: source_campaign,
          category: 'Guns'
        )
      end
      
      let!(:source_weapon) do
        Weapon.create!(
          name: 'Test Weapon',
          campaign: source_campaign,
          damage: 10
        )
      end
      
      let!(:target_schtick) do
        Schtick.create!(
          name: 'Test Schtick',
          campaign: target_campaign,
          category: 'Guns'
        )
      end
      
      let!(:target_weapon) do
        Weapon.create!(
          name: 'Test Weapon',
          campaign: target_campaign,
          damage: 10
        )
      end
      
      before do
        source_character.schticks << source_schtick
        source_character.weapons << source_weapon
      end
      
      it 'maps schticks and weapons to target campaign equivalents' do
        duplicated = CharacterDuplicatorService.duplicate_character(source_character, gamemaster, target_campaign)
        duplicated.save!
        
        CharacterDuplicatorService.apply_associations(duplicated)
        
        expect(duplicated.schticks).to include(target_schtick)
        expect(duplicated.schticks).not_to include(source_schtick)
        
        expect(duplicated.weapons).to include(target_weapon)
        expect(duplicated.weapons).not_to include(source_weapon)
      end
    end
  end
end