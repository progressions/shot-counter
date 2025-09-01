require 'rails_helper'

RSpec.describe CombatActionService do
  before(:each) do
    # Create users
    @gamemaster = User.create!(
      email: "gm@example.com", 
      password: "password", 
      first_name: "Game", 
      last_name: "Master", 
      confirmed_at: Time.current,
      gamemaster: true
    )
    
    @player = User.create!(
      email: "player@example.com",
      password: "password",
      first_name: "Player",
      last_name: "One",
      confirmed_at: Time.current
    )
    
    # Create campaign and fight
    @campaign = Campaign.create!(name: "Test Campaign", user_id: @gamemaster.id)
    @fight = Fight.create!(name: "Test Fight", campaign: @campaign)
    
    # Disable broadcasts for all tests
    allow_any_instance_of(Fight).to receive(:broadcast_encounter_update!)
  end

  describe '#apply_combat_action' do
    context 'PC attacking Featured Foe' do
      before do
        @pc_attacker = Character.create!(
          name: "Jackie",
          campaign: @campaign,
          action_values: { "Type" => "PC", "Fortune" => 3, "Wounds" => 0, "MainAttack" => 15 },
          impairments: 0
        )
        
        @featured_foe = Character.create!(
          name: "Thug Leader",
          campaign: @campaign,
          action_values: { "Type" => "Featured Foe", "Wounds" => 0 },
          impairments: 0
        )
        
        @pc_shot = Shot.create!(fight: @fight, character: @pc_attacker, shot: 15)
        @foe_shot = Shot.create!(fight: @fight, character: @featured_foe, shot: 12, count: 0)
      end
      
      it 'handles successful attack with no defense' do
        character_updates = [
          {
            shot_id: @pc_shot.id,
            character_id: @pc_attacker.id,
            shot: 12,  # 15 - 3 shots
            event: {
              type: "act",
              description: "Jackie acts (3 shots)"
            }
          },
          {
            shot_id: @foe_shot.id,
            character_id: @featured_foe.id,
            wounds: 8,
            impairments: 0,
            event: {
              type: "attack",
              description: "Jackie attacked Thug Leader for 8 wounds"
            }
          }
        ]
        
        CombatActionService.apply_combat_action(@fight, character_updates)
        
        @pc_shot.reload
        @foe_shot.reload
        
        expect(@pc_shot.shot).to eq(12)
        expect(@foe_shot.count).to eq(8)  # NPCs store wounds in shot.count
        expect(@foe_shot.impairments).to eq(0)
        
        events = @fight.fight_events.order(:created_at)
        expect(events.count).to eq(2)
        expect(events[0].description).to eq("Jackie acts (3 shots)")
        expect(events[1].description).to eq("Jackie attacked Thug Leader for 8 wounds")
      end
      
      it 'handles unsuccessful attack (miss)' do
        character_updates = [
          {
            shot_id: @pc_shot.id,
            character_id: @pc_attacker.id,
            shot: 12,
            event: {
              type: "act",
              description: "Jackie acts and misses (3 shots)"
            }
          }
        ]
        
        CombatActionService.apply_combat_action(@fight, character_updates)
        
        @pc_shot.reload
        @foe_shot.reload
        
        expect(@pc_shot.shot).to eq(12)
        expect(@foe_shot.count).to eq(0)  # No wounds
        
        events = @fight.fight_events
        expect(events.count).to eq(1)
        expect(events[0].description).to eq("Jackie acts and misses (3 shots)")
      end
    end
    
    context 'Boss attacking PC' do
      before do
        @boss = Character.create!(
          name: "Big Bad",
          campaign: @campaign,
          action_values: { "Type" => "Boss", "Wounds" => 0 },
          impairments: 0
        )
        
        @pc_defender = Character.create!(
          name: "Hero",
          campaign: @campaign,
          action_values: { "Type" => "PC", "Fortune" => 2, "Wounds" => 0 },
          impairments: 0
        )
        
        @boss_shot = Shot.create!(fight: @fight, character: @boss, shot: 18, count: 0)
        @pc_shot = Shot.create!(fight: @fight, character: @pc_defender, shot: 14)
      end
      
      it 'boss spends only 2 shots to attack' do
        character_updates = [
          {
            shot_id: @boss_shot.id,
            character_id: @boss.id,
            shot: 16,  # 18 - 2 shots (boss cost)
            event: {
              type: "act",
              description: "Big Bad acts (2 shots)"
            }
          },
          {
            shot_id: @pc_shot.id,
            character_id: @pc_defender.id,
            action_values: { "Type" => "PC", "Wounds" => 10, "Fortune" => 2 },
            impairments: 0,
            event: {
              type: "attack",
              description: "Big Bad attacked Hero for 10 wounds"
            }
          }
        ]
        
        CombatActionService.apply_combat_action(@fight, character_updates)
        
        @boss_shot.reload
        @pc_shot.reload
        @pc_defender.reload
        
        expect(@boss_shot.shot).to eq(16)  # Boss only spent 2 shots
        expect(@pc_defender.action_values["Wounds"]).to eq(10)
      end
    end
    
    context 'Defense actions' do
      before do
        @attacker = Character.create!(
          name: "Attacker",
          campaign: @campaign,
          action_values: { "Type" => "PC", "Fortune" => 2, "Wounds" => 0 },
          impairments: 0
        )
        
        @defender = Character.create!(
          name: "Defender",
          campaign: @campaign,
          action_values: { "Type" => "PC", "Fortune" => 3, "Wounds" => 0 },
          impairments: 0
        )
        
        @attacker_shot = Shot.create!(fight: @fight, character: @attacker, shot: 15)
        @defender_shot = Shot.create!(fight: @fight, character: @defender, shot: 12)
      end
      
      it 'handles dodge defense (1 shot cost)' do
        character_updates = [
          {
            shot_id: @attacker_shot.id,
            character_id: @attacker.id,
            shot: 12,
            event: {
              type: "act",
              description: "Attacker acts (3 shots)"
            }
          },
          {
            shot_id: @defender_shot.id,
            character_id: @defender.id,
            shot: 11,  # 12 - 1 for dodge
            event: {
              type: "dodge",
              description: "Defender dodges"
            }
          },
          {
            shot_id: @defender_shot.id,
            character_id: @defender.id,
            action_values: { "Type" => "PC", "Wounds" => 4, "Fortune" => 3 },
            impairments: 0,
            event: {
              type: "attack",
              description: "Attacker attacked Defender (Dodge +3) for 4 wounds"
            }
          }
        ]
        
        CombatActionService.apply_combat_action(@fight, character_updates)
        
        @defender_shot.reload
        @defender.reload
        
        expect(@defender_shot.shot).to eq(11)
        expect(@defender.action_values["Wounds"]).to eq(4)
        expect(@defender.action_values["Fortune"]).to eq(3)  # No fortune spent
      end
      
      it 'handles fortune dodge (1 shot + 1 fortune)' do
        character_updates = [
          {
            shot_id: @attacker_shot.id,
            character_id: @attacker.id,
            shot: 12,
            event: {
              type: "act",
              description: "Attacker acts (3 shots)"
            }
          },
          {
            shot_id: @defender_shot.id,
            character_id: @defender.id,
            shot: 11,  # 12 - 1 for dodge
            action_values: { "Type" => "PC", "Fortune" => 2, "Wounds" => 0 },  # 3 - 1 fortune
            event: {
              type: "dodge",
              description: "Defender dodges with fortune"
            }
          },
          {
            shot_id: @defender_shot.id,
            character_id: @defender.id,
            action_values: { "Type" => "PC", "Wounds" => 2, "Fortune" => 2 },
            impairments: 0,
            event: {
              type: "attack",
              description: "Attacker attacked Defender (Fortune dodge +3 +4) for 2 wounds"
            }
          }
        ]
        
        CombatActionService.apply_combat_action(@fight, character_updates)
        
        @defender_shot.reload
        @defender.reload
        
        expect(@defender_shot.shot).to eq(11)
        expect(@defender.action_values["Wounds"]).to eq(2)
        expect(@defender.action_values["Fortune"]).to eq(2)  # Spent 1 fortune
      end
    end
    
    context 'Impairment thresholds' do
      context 'PC/Ally/Featured Foe (30/35 thresholds)' do
        before do
          @pc = Character.create!(
            name: "Hero",
            campaign: @campaign,
            action_values: { "Type" => "PC", "Wounds" => 28 },
            impairments: 0
          )
          @pc_shot = Shot.create!(fight: @fight, character: @pc, shot: 10)
        end
        
        it 'adds 1 impairment when crossing 30 wounds' do
          character_updates = [
            {
              shot_id: @pc_shot.id,
              character_id: @pc.id,
              action_values: { "Type" => "PC", "Wounds" => 32 },  # 28 + 4 damage
              impairments: 1,
              event: {
                type: "attack",
                description: "Attack for 4 wounds"
              }
            }
          ]
          
          CombatActionService.apply_combat_action(@fight, character_updates)
          
          @pc.reload
          expect(@pc.action_values["Wounds"]).to eq(32)
          expect(@pc.impairments).to eq(1)
        end
        
        it 'adds 2 impairments when crossing both 30 and 35 wounds' do
          character_updates = [
            {
              shot_id: @pc_shot.id,
              character_id: @pc.id,
              action_values: { "Type" => "PC", "Wounds" => 36 },  # 28 + 8 damage
              impairments: 2,
              event: {
                type: "attack",
                description: "Attack for 8 wounds"
              }
            }
          ]
          
          CombatActionService.apply_combat_action(@fight, character_updates)
          
          @pc.reload
          expect(@pc.action_values["Wounds"]).to eq(36)
          expect(@pc.impairments).to eq(2)
        end
        
        it 'adds only 1 impairment when going from 32 to 37 (crosses 35 only)' do
          @pc.update!(action_values: { "Type" => "PC", "Wounds" => 32 }, impairments: 1)
          
          character_updates = [
            {
              shot_id: @pc_shot.id,
              character_id: @pc.id,
              action_values: { "Type" => "PC", "Wounds" => 37 },  # 32 + 5 damage
              impairments: 2,  # 1 existing + 1 new
              event: {
                type: "attack",
                description: "Attack for 5 wounds"
              }
            }
          ]
          
          CombatActionService.apply_combat_action(@fight, character_updates)
          
          @pc.reload
          expect(@pc.action_values["Wounds"]).to eq(37)
          expect(@pc.impairments).to eq(2)
        end
      end
      
      context 'Boss/Uber Boss (45/50 thresholds)' do
        before do
          @boss = Character.create!(
            name: "Big Boss",
            campaign: @campaign,
            action_values: { "Type" => "Boss", "Wounds" => 0 },
            impairments: 0
          )
          @boss_shot = Shot.create!(fight: @fight, character: @boss, shot: 10, count: 43)
        end
        
        it 'adds 1 impairment when crossing 45 wounds' do
          character_updates = [
            {
              shot_id: @boss_shot.id,
              character_id: @boss.id,
              wounds: 47,  # 43 + 4 damage
              impairments: 1,
              event: {
                type: "attack",
                description: "Attack for 4 wounds"
              }
            }
          ]
          
          CombatActionService.apply_combat_action(@fight, character_updates)
          
          @boss_shot.reload
          expect(@boss_shot.count).to eq(47)
          expect(@boss_shot.impairments).to eq(1)
        end
        
        it 'adds 2 impairments when crossing both 45 and 50 wounds' do
          character_updates = [
            {
              shot_id: @boss_shot.id,
              character_id: @boss.id,
              wounds: 52,  # 43 + 9 damage
              impairments: 2,
              event: {
                type: "attack",
                description: "Attack for 9 wounds"
              }
            }
          ]
          
          CombatActionService.apply_combat_action(@fight, character_updates)
          
          @boss_shot.reload
          expect(@boss_shot.count).to eq(52)
          expect(@boss_shot.impairments).to eq(2)
        end
      end
    end
    
    context 'Multi-target attacks' do
      before do
        @attacker = Character.create!(
          name: "Jackie",
          campaign: @campaign,
          action_values: { "Type" => "PC", "Fortune" => 3, "Wounds" => 0 },
          impairments: 0
        )
        
        @target1 = Character.create!(
          name: "Thug 1",
          campaign: @campaign,
          action_values: { "Type" => "Featured Foe", "Wounds" => 0 },
          impairments: 0
        )
        
        @target2 = Character.create!(
          name: "Thug 2",
          campaign: @campaign,
          action_values: { "Type" => "Featured Foe", "Wounds" => 0 },
          impairments: 0
        )
        
        @target3 = Character.create!(
          name: "Hero Ally",
          campaign: @campaign,
          action_values: { "Type" => "PC", "Fortune" => 2, "Wounds" => 0 },
          impairments: 0
        )
        
        @attacker_shot = Shot.create!(fight: @fight, character: @attacker, shot: 15)
        @target1_shot = Shot.create!(fight: @fight, character: @target1, shot: 12, count: 0)
        @target2_shot = Shot.create!(fight: @fight, character: @target2, shot: 10, count: 0)
        @target3_shot = Shot.create!(fight: @fight, character: @target3, shot: 8)
      end
      
      it 'handles attacking multiple targets with mixed defenses' do
        character_updates = [
          # Attacker acts
          {
            shot_id: @attacker_shot.id,
            character_id: @attacker.id,
            shot: 12,  # Spends 3 shots
            event: {
              type: "act",
              description: "Jackie acts (3 shots)"
            }
          },
          # Target 1: no defense, takes full damage
          {
            shot_id: @target1_shot.id,
            character_id: @target1.id,
            wounds: 8,
            impairments: 0,
            event: {
              type: "attack",
              description: "Jackie attacked Thug 1 for 8 wounds"
            }
          },
          # Target 2: dodges
          {
            shot_id: @target2_shot.id,
            character_id: @target2.id,
            shot: 9,  # 10 - 1 for dodge
            event: {
              type: "dodge",
              description: "Thug 2 dodges"
            }
          },
          {
            shot_id: @target2_shot.id,
            character_id: @target2.id,
            wounds: 4,
            impairments: 0,
            event: {
              type: "attack",
              description: "Jackie attacked Thug 2 (Dodge +3) for 4 wounds"
            }
          },
          # Target 3: fortune dodge
          {
            shot_id: @target3_shot.id,
            character_id: @target3.id,
            shot: 7,  # 8 - 1 for dodge
            action_values: { "Type" => "PC", "Fortune" => 1, "Wounds" => 0 },  # Spends 1 fortune
            event: {
              type: "dodge",
              description: "Hero Ally dodges with fortune"
            }
          },
          {
            shot_id: @target3_shot.id,
            character_id: @target3.id,
            action_values: { "Type" => "PC", "Wounds" => 2, "Fortune" => 1 },
            impairments: 0,
            event: {
              type: "attack",
              description: "Jackie attacked Hero Ally (Fortune dodge +3 +3) for 2 wounds"
            }
          }
        ]
        
        CombatActionService.apply_combat_action(@fight, character_updates)
        
        # Verify all changes
        @attacker_shot.reload
        @target1_shot.reload
        @target2_shot.reload
        @target3_shot.reload
        @target3.reload
        
        expect(@attacker_shot.shot).to eq(12)
        expect(@target1_shot.count).to eq(8)
        expect(@target2_shot.shot).to eq(9)
        expect(@target2_shot.count).to eq(4)
        expect(@target3_shot.shot).to eq(7)
        expect(@target3.action_values["Wounds"]).to eq(2)
        expect(@target3.action_values["Fortune"]).to eq(1)
        
        events = @fight.fight_events.order(:created_at)
        expect(events.count).to eq(6)
      end
      
      it 'handles boss attacking multiple PCs' do
        @boss = Character.create!(
          name: "Big Boss",
          campaign: @campaign,
          action_values: { "Type" => "Boss", "Wounds" => 0 },
          impairments: 0
        )
        @boss_shot = Shot.create!(fight: @fight, character: @boss, shot: 20, count: 0)
        
        character_updates = [
          # Boss acts (2 shot cost)
          {
            shot_id: @boss_shot.id,
            character_id: @boss.id,
            shot: 18,  # Boss spends only 2 shots
            event: {
              type: "act",
              description: "Big Boss acts (2 shots)"
            }
          },
          # Attack all three targets
          {
            shot_id: @target1_shot.id,
            character_id: @target1.id,
            wounds: 10,
            impairments: 0,
            event: {
              type: "attack",
              description: "Big Boss attacked Thug 1 for 10 wounds"
            }
          },
          {
            shot_id: @target2_shot.id,
            character_id: @target2.id,
            wounds: 10,
            impairments: 0,
            event: {
              type: "attack",
              description: "Big Boss attacked Thug 2 for 10 wounds"
            }
          },
          {
            shot_id: @target3_shot.id,
            character_id: @target3.id,
            action_values: { "Type" => "PC", "Wounds" => 10, "Fortune" => 2 },
            impairments: 0,
            event: {
              type: "attack",
              description: "Big Boss attacked Hero Ally for 10 wounds"
            }
          }
        ]
        
        CombatActionService.apply_combat_action(@fight, character_updates)
        
        @boss_shot.reload
        expect(@boss_shot.shot).to eq(18)  # Boss only spent 2 shots
        
        @target1_shot.reload
        @target2_shot.reload
        @target3.reload
        
        expect(@target1_shot.count).to eq(10)
        expect(@target2_shot.count).to eq(10)
        expect(@target3.action_values["Wounds"]).to eq(10)
      end
    end
    
    context 'Mook scenarios' do
      before do
        @attacker = Character.create!(
          name: "Hero",
          campaign: @campaign,
          action_values: { "Type" => "PC", "Wounds" => 0 },
          impairments: 0
        )
        
        @mook_group = Character.create!(
          name: "Thugs",
          campaign: @campaign,
          action_values: { "Type" => "Mook" }
        )
        
        @attacker_shot = Shot.create!(fight: @fight, character: @attacker, shot: 15)
        @mook_shot = Shot.create!(fight: @fight, character: @mook_group, shot: 8, count: 10)
      end
      
      it 'reduces mook count when attacked' do
        character_updates = [
          {
            shot_id: @attacker_shot.id,
            character_id: @attacker.id,
            shot: 12,
            event: {
              type: "act",
              description: "Hero acts (3 shots)"
            }
          },
          {
            shot_id: @mook_shot.id,
            character_id: @mook_group.id,
            count: 7,  # 10 - 3 taken out
            event: {
              type: "attack",
              description: "Hero took out 3 mooks"
            }
          }
        ]
        
        CombatActionService.apply_combat_action(@fight, character_updates)
        
        @mook_shot.reload
        expect(@mook_shot.count).to eq(7)
      end
      
      it 'handles total mook elimination' do
        @mook_shot.update!(count: 3)
        
        character_updates = [
          {
            shot_id: @attacker_shot.id,
            character_id: @attacker.id,
            shot: 12,
            event: {
              type: "act",
              description: "Hero acts (3 shots)"
            }
          },
          {
            shot_id: @mook_shot.id,
            character_id: @mook_group.id,
            count: 0,  # All eliminated
            event: {
              type: "attack",
              description: "Hero took out all 3 remaining mooks"
            }
          }
        ]
        
        CombatActionService.apply_combat_action(@fight, character_updates)
        
        @mook_shot.reload
        expect(@mook_shot.count).to eq(0)
      end
      
      it 'handles mook group attacking PC' do
        @pc_target = Character.create!(
          name: "Target",
          campaign: @campaign,
          action_values: { "Type" => "PC", "Wounds" => 0 },
          impairments: 0
        )
        @pc_target_shot = Shot.create!(fight: @fight, character: @pc_target, shot: 10)
        
        character_updates = [
          {
            shot_id: @mook_shot.id,
            character_id: @mook_group.id,
            shot: 5,  # Mooks spend 3 shots
            event: {
              type: "act",
              description: "Thugs act (3 shots)"
            }
          },
          {
            shot_id: @pc_target_shot.id,
            character_id: @pc_target.id,
            action_values: { "Type" => "PC", "Wounds" => 6 },
            impairments: 0,
            event: {
              type: "attack",
              description: "Thugs attacked Target for 6 wounds"
            }
          }
        ]
        
        CombatActionService.apply_combat_action(@fight, character_updates)
        
        @mook_shot.reload
        @pc_target.reload
        
        expect(@mook_shot.shot).to eq(5)
        expect(@pc_target.action_values["Wounds"]).to eq(6)
      end
    end
    
    context 'Fortune spending variations' do
      before do
        @attacker = Character.create!(
          name: "Attacker",
          campaign: @campaign,
          action_values: { "Type" => "PC", "Fortune" => 3, "Wounds" => 0 },
          impairments: 0
        )
        
        @defender = Character.create!(
          name: "Defender",
          campaign: @campaign,
          action_values: { "Type" => "PC", "Fortune" => 1, "Wounds" => 0 },
          impairments: 0
        )
        
        @attacker_shot = Shot.create!(fight: @fight, character: @attacker, shot: 15)
        @defender_shot = Shot.create!(fight: @fight, character: @defender, shot: 12)
      end
      
      it 'handles attacker spending fortune for extra damage' do
        character_updates = [
          {
            shot_id: @attacker_shot.id,
            character_id: @attacker.id,
            shot: 12,
            action_values: { "Type" => "PC", "Fortune" => 2, "Wounds" => 0 },  # Spent 1 fortune
            event: {
              type: "act",
              description: "Attacker acts with fortune (3 shots, 1 fortune)"
            }
          },
          {
            shot_id: @defender_shot.id,
            character_id: @defender.id,
            action_values: { "Type" => "PC", "Wounds" => 12, "Fortune" => 1 },
            impairments: 0,
            event: {
              type: "attack",
              description: "Attacker attacked Defender for 12 wounds (fortune bonus)"
            }
          }
        ]
        
        CombatActionService.apply_combat_action(@fight, character_updates)
        
        @attacker.reload
        @defender.reload
        
        expect(@attacker.action_values["Fortune"]).to eq(2)
        expect(@defender.action_values["Wounds"]).to eq(12)
      end
      
      it 'handles defender with no fortune attempting fortune dodge' do
        @defender.update!(action_values: { "Type" => "PC", "Fortune" => 0, "Wounds" => 0 })
        
        character_updates = [
          {
            shot_id: @attacker_shot.id,
            character_id: @attacker.id,
            shot: 12,
            event: {
              type: "act",
              description: "Attacker acts (3 shots)"
            }
          },
          # Defender cannot fortune dodge with 0 fortune
          {
            shot_id: @defender_shot.id,
            character_id: @defender.id,
            action_values: { "Type" => "PC", "Wounds" => 8, "Fortune" => 0 },
            impairments: 0,
            event: {
              type: "attack",
              description: "Attacker attacked Defender for 8 wounds"
            }
          }
        ]
        
        CombatActionService.apply_combat_action(@fight, character_updates)
        
        @defender.reload
        expect(@defender.action_values["Fortune"]).to eq(0)
        expect(@defender.action_values["Wounds"]).to eq(8)
      end
    end
    
    context 'Edge cases' do
      before do
        @character = Character.create!(
          name: "Test Character",
          campaign: @campaign,
          action_values: { "Type" => "PC", "Wounds" => 0 },
          impairments: 0
        )
        @shot = Shot.create!(fight: @fight, character: @character, shot: 3)
      end
      
      it 'handles character at shot 3 spending 3 shots' do
        character_updates = [
          {
            shot_id: @shot.id,
            character_id: @character.id,
            shot: 0,
            event: {
              type: "act",
              description: "Test Character acts (3 shots)"
            }
          }
        ]
        
        CombatActionService.apply_combat_action(@fight, character_updates)
        
        @shot.reload
        expect(@shot.shot).to eq(0)
      end
      
      it 'rolls back transaction on invalid character_id' do
        expect {
          character_updates = [
            {
              shot_id: @shot.id,
              character_id: "invalid-id",
              shot: 0,
              event: {
                type: "act",
                description: "Invalid action"
              }
            }
          ]
          
          CombatActionService.apply_combat_action(@fight, character_updates)
        }.to raise_error(ActiveRecord::RecordNotFound)
        
        @shot.reload
        expect(@shot.shot).to eq(3)  # Unchanged
      end
      
      it 'rolls back transaction on invalid shot_id' do
        expect {
          character_updates = [
            {
              shot_id: "invalid-shot-id",
              character_id: @character.id,
              shot: 0,
              event: {
                type: "act",
                description: "Invalid action"
              }
            }
          ]
          
          CombatActionService.apply_combat_action(@fight, character_updates)
        }.to raise_error(ActiveRecord::RecordNotFound)
        
        @shot.reload
        expect(@shot.shot).to eq(3)  # Unchanged
      end
    end
    
    context 'WebSocket broadcasting' do
      it 'broadcasts only once after all updates' do
        @attacker = Character.create!(
          name: "Attacker",
          campaign: @campaign,
          action_values: { "Type" => "PC", "Wounds" => 0 },
          impairments: 0
        )
        
        @defender1 = Character.create!(
          name: "Defender 1",
          campaign: @campaign,
          action_values: { "Type" => "PC", "Wounds" => 0 },
          impairments: 0
        )
        
        @defender2 = Character.create!(
          name: "Defender 2",
          campaign: @campaign,
          action_values: { "Type" => "PC", "Wounds" => 0 },
          impairments: 0
        )
        
        @attacker_shot = Shot.create!(fight: @fight, character: @attacker, shot: 15)
        @defender1_shot = Shot.create!(fight: @fight, character: @defender1, shot: 12)
        @defender2_shot = Shot.create!(fight: @fight, character: @defender2, shot: 10)
        
        # Mock the broadcast method to count calls
        broadcast_count = 0
        allow(@fight).to receive(:broadcast_encounter_update!) do
          broadcast_count += 1
        end
        
        character_updates = [
          {
            shot_id: @attacker_shot.id,
            character_id: @attacker.id,
            shot: 12,
            event: {
              type: "act",
              description: "Attacker acts"
            }
          },
          {
            shot_id: @defender1_shot.id,
            character_id: @defender1.id,
            action_values: { "Type" => "PC", "Wounds" => 5 },
            impairments: 0,
            event: {
              type: "attack",
              description: "Attack defender 1"
            }
          },
          {
            shot_id: @defender2_shot.id,
            character_id: @defender2.id,
            action_values: { "Type" => "PC", "Wounds" => 5 },
            impairments: 0,
            event: {
              type: "attack",
              description: "Attack defender 2"
            }
          }
        ]
        
        CombatActionService.apply_combat_action(@fight, character_updates)
        
        # Should have received exactly one broadcast
        expect(broadcast_count).to eq(1)
      end
      
      it 'disables broadcasts during transaction' do
        @character = Character.create!(
          name: "Test",
          campaign: @campaign,
          action_values: { "Type" => "PC", "Wounds" => 0 },
          impairments: 0
        )
        @shot = Shot.create!(fight: @fight, character: @character, shot: 10)
        
        # Track Thread.current[:disable_broadcasts] states
        broadcast_states = []
        original_method = Thread.current.method(:[]=)
        allow(Thread.current).to receive(:[]=) do |key, value|
          if key == :disable_broadcasts
            broadcast_states << value
          end
          original_method.call(key, value)
        end
        
        character_updates = [
          {
            shot_id: @shot.id,
            character_id: @character.id,
            shot: 7,
            event: {
              type: "act",
              description: "Test acts"
            }
          }
        ]
        
        CombatActionService.apply_combat_action(@fight, character_updates)
        
        # Should disable then re-enable broadcasts
        expect(broadcast_states).to eq([true, false])
      end
    end
    
    context 'Complex combat round with all features' do
      it 'handles complete multi-target attack with fortune and various defenses' do
        # Setup characters
        @pc_attacker = Character.create!(
          name: "Jackie",
          campaign: @campaign,
          action_values: { "Type" => "PC", "Fortune" => 3, "Wounds" => 0 },
          impairments: 0
        )
        
        @pc_defender = Character.create!(
          name: "Tommy",
          campaign: @campaign,
          action_values: { "Type" => "PC", "Fortune" => 2, "Wounds" => 28 },
          impairments: 0
        )
        
        @featured_foe = Character.create!(
          name: "Thug Leader",
          campaign: @campaign,
          action_values: { "Type" => "Featured Foe", "Wounds" => 0 },
          impairments: 0
        )
        
        @boss = Character.create!(
          name: "Big Boss",
          campaign: @campaign,
          action_values: { "Type" => "Boss", "Wounds" => 0 },
          impairments: 0
        )
        
        # Create shots
        @attacker_shot = Shot.create!(fight: @fight, character: @pc_attacker, shot: 15)
        @pc_def_shot = Shot.create!(fight: @fight, character: @pc_defender, shot: 12)
        @foe_shot = Shot.create!(fight: @fight, character: @featured_foe, shot: 10, count: 28)
        @boss_shot = Shot.create!(fight: @fight, character: @boss, shot: 8, count: 44)
        
        character_updates = [
          # Attacker acts with fortune
          {
            shot_id: @attacker_shot.id,
            character_id: @pc_attacker.id,
            shot: 12,
            action_values: { "Type" => "PC", "Fortune" => 2, "Wounds" => 0 },
            event: {
              type: "act",
              description: "Jackie acts with fortune (3 shots, 1 fortune)"
            }
          },
          # PC defender uses fortune dodge
          {
            shot_id: @pc_def_shot.id,
            character_id: @pc_defender.id,
            shot: 11,
            action_values: { "Type" => "PC", "Fortune" => 1, "Wounds" => 28 },
            event: {
              type: "dodge",
              description: "Tommy dodges with fortune"
            }
          },
          {
            shot_id: @pc_def_shot.id,
            character_id: @pc_defender.id,
            action_values: { "Type" => "PC", "Wounds" => 32, "Fortune" => 1 },
            impairments: 1,  # Crosses 30 threshold
            event: {
              type: "attack",
              description: "Jackie attacked Tommy (Fortune dodge +3 +4) for 4 wounds"
            }
          },
          # Featured foe dodges normally
          {
            shot_id: @foe_shot.id,
            character_id: @featured_foe.id,
            shot: 9,
            event: {
              type: "dodge",
              description: "Thug Leader dodges"
            }
          },
          {
            shot_id: @foe_shot.id,
            character_id: @featured_foe.id,
            wounds: 36,  # 28 + 8, crosses 30 and 35
            impairments: 2,
            event: {
              type: "attack",
              description: "Jackie attacked Thug Leader (Dodge +3) for 8 wounds"
            }
          },
          # Boss takes hit without defense
          {
            shot_id: @boss_shot.id,
            character_id: @boss.id,
            wounds: 51,  # 44 + 7, crosses 45 and 50
            impairments: 2,
            event: {
              type: "attack",
              description: "Jackie attacked Big Boss for 7 wounds"
            }
          }
        ]
        
        CombatActionService.apply_combat_action(@fight, character_updates)
        
        # Verify all changes
        @attacker_shot.reload
        @pc_attacker.reload
        @pc_def_shot.reload
        @pc_defender.reload
        @foe_shot.reload
        @boss_shot.reload
        
        # Attacker
        expect(@attacker_shot.shot).to eq(12)
        expect(@pc_attacker.action_values["Fortune"]).to eq(2)
        
        # PC defender
        expect(@pc_def_shot.shot).to eq(11)
        expect(@pc_defender.action_values["Wounds"]).to eq(32)
        expect(@pc_defender.action_values["Fortune"]).to eq(1)
        expect(@pc_defender.impairments).to eq(1)
        
        # Featured foe
        expect(@foe_shot.shot).to eq(9)
        expect(@foe_shot.count).to eq(36)
        expect(@foe_shot.impairments).to eq(2)
        
        # Boss
        expect(@boss_shot.count).to eq(51)
        expect(@boss_shot.impairments).to eq(2)
        
        # Events
        events = @fight.fight_events.order(:created_at)
        expect(events.count).to eq(6)
      end
    end
  end
end