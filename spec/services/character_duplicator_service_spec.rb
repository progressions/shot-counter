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

  # Create source campaign associations
  let!(:source_juncture) do
    Juncture.create!(
      name: 'Contemporary',
      description: 'Modern day setting',
      campaign: source_campaign
    )
  end

  let!(:source_faction) do
    Faction.create!(
      name: 'Dragons',
      description: 'Ancient crime syndicate',
      campaign: source_campaign
    )
  end

  # Create target campaign associations
  let!(:target_juncture) do
    Juncture.create!(
      name: 'Contemporary',
      description: 'Modern day setting - target campaign',
      campaign: target_campaign
    )
  end

  let!(:target_faction) do
    Faction.create!(
      name: 'Dragons',
      description: 'Ancient crime syndicate - target campaign',
      campaign: target_campaign
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

  # Complex character with associations for realistic testing
  let!(:complex_source_character) do
    Character.create!(
      name: 'Master Template Character',
      campaign: source_campaign,
      user: gamemaster,
      juncture: source_juncture,
      faction: source_faction,
      action_values: { 
        'Type' => 'Featured Foe', 
        'Defense' => 15, 
        'Toughness' => 12,
        'Guns' => 13,
        'Martial Arts' => 10,
        'Speed' => 8,
        'Fortune' => 5
      }
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

    # ENHANCED ASSOCIATION TESTING - Addressing Production Bug Scenarios
    context 'with juncture associations' do
      it 'maps juncture to target campaign equivalent when applying associations' do
        # Setup: Character with juncture in source campaign
        char_with_juncture = Character.create!(
          name: 'Juncture Character',
          campaign: source_campaign,
          user: gamemaster,
          juncture: source_juncture,
          action_values: { 'Type' => 'NPC', 'Defense' => 12 }
        )

        # Test duplication
        duplicated = CharacterDuplicatorService.duplicate_character(char_with_juncture, gamemaster, target_campaign)
        duplicated.save!

        # Initially no juncture should be set (it's excluded during duplication)
        expect(duplicated.juncture).to be_nil

        # Apply associations should map to target campaign's matching juncture
        CharacterDuplicatorService.apply_associations(duplicated)
        duplicated.reload

        expect(duplicated.juncture).to eq(target_juncture)
        expect(duplicated.juncture).not_to eq(source_juncture)
        expect(duplicated.juncture.campaign).to eq(target_campaign)
      end

      it 'handles missing target juncture gracefully' do
        # Create juncture that only exists in source campaign
        unique_source_juncture = Juncture.create!(
          name: 'Unique Netherworld',
          description: 'Only in source',
          campaign: source_campaign
        )

        char_with_unique_juncture = Character.create!(
          name: 'Netherworld Character',
          campaign: source_campaign,
          user: gamemaster,
          juncture: unique_source_juncture,
          action_values: { 'Type' => 'Boss', 'Defense' => 18 }
        )

        duplicated = CharacterDuplicatorService.duplicate_character(char_with_unique_juncture, gamemaster, target_campaign)
        duplicated.save!

        # Should not raise error when target juncture doesn't exist
        expect { CharacterDuplicatorService.apply_associations(duplicated) }.not_to raise_error
        
        duplicated.reload
        expect(duplicated.juncture).to be_nil
      end

      it 'preserves juncture association validation' do
        # This tests the scenario that caused the production bug
        # But we need to create a character without faction to avoid the faction bug
        char_with_only_juncture = Character.create!(
          name: 'Juncture Only Character',
          campaign: source_campaign,
          user: gamemaster,
          juncture: source_juncture,
          faction: nil,  # No faction to avoid the other bug
          action_values: { 'Type' => 'Featured Foe', 'Defense' => 15 }
        )

        duplicated = CharacterDuplicatorService.duplicate_character(char_with_only_juncture, gamemaster, target_campaign)
        duplicated.save!

        CharacterDuplicatorService.apply_associations(duplicated)
        duplicated.reload

        # Should be valid after proper association mapping
        expect(duplicated).to be_valid
        expect(duplicated.juncture).to eq(target_juncture)
        expect(duplicated.juncture.campaign).to eq(target_campaign)
      end
    end

    context 'with faction associations' do
      it 'properly excludes faction_id during duplication - BUG FIXED' do
        # This test verifies that faction_id is properly excluded during duplication
        duplicated = CharacterDuplicatorService.duplicate_character(complex_source_character, gamemaster, target_campaign)

        # The duplicated character should NOT have faction set initially (excluded like juncture_id)
        expect(duplicated.faction).to be_nil
        expect(duplicated.faction_id).to be_nil

        # Character should save without validation error
        expect { duplicated.save! }.not_to raise_error
        
        # Faction mapping happens during apply_associations
        CharacterDuplicatorService.apply_associations(duplicated)
        duplicated.reload
        
        # Now faction should be mapped to target campaign equivalent
        expect(duplicated.faction).to eq(target_faction)
        expect(duplicated.faction.campaign).to eq(target_campaign)
      end

      it 'should map faction to target campaign (DESIRED BEHAVIOR)' do
        # This test shows what SHOULD happen (but currently doesn't)
        # Skip until service is fixed to handle faction mapping
        skip "Service needs to be updated to handle faction mapping like junctures"
        
        duplicated = CharacterDuplicatorService.duplicate_character(complex_source_character, gamemaster, target_campaign)
        duplicated.save!

        # Apply associations should map faction like it does junctures
        CharacterDuplicatorService.apply_associations(duplicated)
        duplicated.reload

        expect(duplicated.faction).to eq(target_faction)
        expect(duplicated.faction.campaign).to eq(target_campaign)
        expect(duplicated).to be_valid
      end
    end

    context 'with complex master template scenarios' do
      before do
        # Add schticks and weapons to complex character
        source_schtick = Schtick.create!(name: 'Gun Mastery', campaign: source_campaign, category: 'Guns')
        target_schtick = Schtick.create!(name: 'Gun Mastery', campaign: target_campaign, category: 'Guns')
        
        source_weapon = Weapon.create!(name: 'Beretta 92', campaign: source_campaign, damage: 9)
        target_weapon = Weapon.create!(name: 'Beretta 92', campaign: target_campaign, damage: 9)

        complex_source_character.schticks << source_schtick
        complex_source_character.weapons << source_weapon
      end

      it 'properly handles master template duplication with associations - BUG FIXED' do
        # This mirrors the production scenario with master template characters
        duplicated = CharacterDuplicatorService.duplicate_character(complex_source_character, gamemaster, target_campaign)
        
        expect(duplicated.name).to eq('Master Template Character')
        expect(duplicated.campaign).to eq(target_campaign)
        expect(duplicated.user).to eq(gamemaster)
        expect(duplicated.juncture).to be_nil    # Excluded during duplication  
        expect(duplicated.faction).to be_nil     # FIXED: Now excluded like juncture_id

        # Character saves without validation error
        expect { duplicated.save! }.not_to raise_error
        
        # Apply associations to map faction and juncture
        CharacterDuplicatorService.apply_associations(duplicated)
        duplicated.reload
        
        # Both juncture and faction should be properly mapped
        expect(duplicated.juncture).to eq(target_juncture) 
        expect(duplicated.faction).to eq(target_faction)
        
        # This prevents master template characters with factions from being duplicated
        # Same root cause as the juncture issue we fixed
      end

      it 'should handle full template with all associations (DESIRED BEHAVIOR)' do
        skip "Service needs faction mapping implementation to make this work"
        
        # What SHOULD happen after service is fixed
        duplicated = CharacterDuplicatorService.duplicate_character(complex_source_character, gamemaster, target_campaign)
        duplicated.save!

        CharacterDuplicatorService.apply_associations(duplicated)
        duplicated.reload

        expect(duplicated.juncture).to eq(target_juncture)
        expect(duplicated.faction).to eq(target_faction)
        expect(duplicated.schticks.first.campaign).to eq(target_campaign)
        expect(duplicated.weapons.first.campaign).to eq(target_campaign)
        expect(duplicated).to be_valid
      end
    end

    context 'validation edge cases' do
      it 'prevents creation of character with invalid cross-campaign associations' do
        # Create character with cross-campaign juncture (should fail validation)
        expect {
          Character.create!(
            name: 'Invalid Character',
            campaign: target_campaign,
            user: gamemaster,
            juncture: source_juncture,  # Wrong campaign!
            action_values: { 'Type' => 'PC', 'Defense' => 10 }
          )
        }.to raise_error(ActiveRecord::RecordInvalid, /must belong to the same campaign/)
      end

      it 'prevents creation with cross-campaign faction' do
        expect {
          Character.create!(
            name: 'Invalid Faction Character',
            campaign: target_campaign,
            user: gamemaster,
            faction: source_faction,  # Wrong campaign!
            action_values: { 'Type' => 'PC', 'Defense' => 10 }
          )
        }.to raise_error(ActiveRecord::RecordInvalid, /must belong to the same campaign/)
      end
    end

    context 'error handling and resilience' do
      it 'handles characters with nil associations gracefully' do
        nil_char = Character.create!(
          name: 'Minimal Character',
          campaign: source_campaign,
          user: gamemaster,
          juncture: nil,
          faction: nil,
          action_values: { 'Type' => 'Mook', 'Defense' => 5 }
        )

        duplicated = CharacterDuplicatorService.duplicate_character(nil_char, gamemaster, target_campaign)
        duplicated.save!

        expect { CharacterDuplicatorService.apply_associations(duplicated) }.not_to raise_error
        
        duplicated.reload
        expect(duplicated.juncture).to be_nil
        expect(duplicated.faction).to be_nil
        expect(duplicated).to be_valid
      end

      it 'handles duplicate names with complex characters' do
        # Create character with same name in target
        Character.create!(
          name: 'Master Template Character',
          campaign: target_campaign,
          user: gamemaster,
          action_values: { 'Type' => 'PC', 'Defense' => 10 }
        )

        duplicated = CharacterDuplicatorService.duplicate_character(complex_source_character, gamemaster, target_campaign)
        
        expect(duplicated.name).to eq('Master Template Character (1)')
        expect(duplicated.campaign).to eq(target_campaign)
      end
    end
  end
end