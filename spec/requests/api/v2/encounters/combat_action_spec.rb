require "rails_helper"

RSpec.describe "Api::V2::Encounters::CombatAction", type: :request do
  before(:each) do
    allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
    
    # Users
    @gamemaster = User.create!(
      email: "gamemaster@example.com", 
      confirmed_at: Time.now, 
      gamemaster: true, 
      first_name: "Game", 
      last_name: "Master", 
      name: "Game Master"
    )
    @player = User.create!(
      email: "player@example.com", 
      confirmed_at: Time.now, 
      gamemaster: false, 
      first_name: "Player", 
      last_name: "One", 
      name: "Player One"
    )
    
    # Campaign setup
    @campaign = @gamemaster.campaigns.create!(name: "Test Campaign")
    
    # Fight setup - must be started to allow combat actions
    @fight = @campaign.fights.create!(
      name: "Test Fight", 
      description: "A test combat",
      started_at: 1.hour.ago  # Fight must be active for broadcasts
    )
    
    # Auth headers
    @gamemaster_headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    @player_headers = Devise::JWT::TestHelpers.auth_headers({}, @player)
    
    # Set current campaign for both users
    set_current_campaign(@gamemaster, @campaign)
    set_current_campaign(@player, @campaign)
    
    Rails.cache.clear
  end

  describe "POST /api/v2/encounters/:id/apply_combat_action" do
    context "when user is not authenticated" do
      it "returns unauthorized" do
        post "/api/v2/encounters/#{@fight.id}/apply_combat_action", 
          params: { character_updates: [] }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when fight does not exist" do
      it "returns not found" do
        post "/api/v2/encounters/invalid-id/apply_combat_action",
          params: { character_updates: [] },
          headers: @gamemaster_headers
        expect(response).to have_http_status(:not_found)
      end
    end

    context "PC attacking Featured Foe" do
      before do
        @pc_attacker = Character.create!(
          name: "Jackie",
          campaign: @campaign,
          user: @player,
          action_values: { "Type" => "PC", "Fortune" => 3, "Wounds" => 0, "MainAttack" => "Martial Arts", "Martial Arts" => 14 },
          impairments: 0
        )
        @featured_foe = Character.create!(
          name: "Thug Leader",
          campaign: @campaign,
          action_values: { "Type" => "Featured Foe" }
        )
        @pc_shot = Shot.create!(fight: @fight, character: @pc_attacker, shot: 15)
        @foe_shot = Shot.create!(fight: @fight, character: @featured_foe, shot: 10, count: 0)
      end

      it "handles successful attack with wounds applied" do
        character_updates = [
          {
            shot_id: @pc_shot.id,
            character_id: @pc_attacker.id,
            shot: 12,  # PC spends 3 shots
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

        post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
          params: { character_updates: character_updates },
          headers: @player_headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["id"]).to eq(@fight.id)
        
        # Verify changes were applied
        @pc_shot.reload
        @foe_shot.reload
        expect(@pc_shot.shot).to eq(12)
        expect(@foe_shot.count).to eq(8)
      end

      it "handles miss (no wounds)" do
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

        post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
          params: { character_updates: character_updates },
          headers: @player_headers

        expect(response).to have_http_status(:ok)
        @pc_shot.reload
        expect(@pc_shot.shot).to eq(12)
      end
    end

    context "Boss attacking PC" do
      before do
        @boss = Character.create!(
          name: "Big Boss",
          campaign: @campaign,
          action_values: { "Type" => "Boss", "MainAttack" => "Martial Arts", "Martial Arts" => 16 },
          impairments: 0
        )
        @pc_target = Character.create!(
          name: "Hero",
          campaign: @campaign,
          user: @player,
          action_values: { "Type" => "PC", "Wounds" => 0 },
          impairments: 0
        )
        @boss_shot = Shot.create!(fight: @fight, character: @boss, shot: 20, count: 0)
        @pc_shot = Shot.create!(fight: @fight, character: @pc_target, shot: 15)
      end

      it "boss spends only 2 shots to attack" do
        character_updates = [
          {
            shot_id: @boss_shot.id,
            character_id: @boss.id,
            shot: 18,  # Boss only spends 2 shots
            event: {
              type: "act",
              description: "Big Boss acts (2 shots)"
            }
          },
          {
            shot_id: @pc_shot.id,
            character_id: @pc_target.id,
            action_values: { "Type" => "PC", "Wounds" => 10 },
            impairments: 0,
            event: {
              type: "attack",
              description: "Big Boss attacked Hero for 10 wounds"
            }
          }
        ]

        post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
          params: { character_updates: character_updates },
          headers: @gamemaster_headers

        expect(response).to have_http_status(:ok)
        
        @boss_shot.reload
        @pc_target.reload
        expect(@boss_shot.shot).to eq(18)
        expect(@pc_target.action_values["Wounds"]).to eq(10)
      end
    end

    context "Defense actions" do
      before do
        @attacker = Character.create!(
          name: "Attacker",
          campaign: @campaign,
          action_values: { "Type" => "PC", "Wounds" => 0 },
          impairments: 0
        )
        @defender = Character.create!(
          name: "Defender",
          campaign: @campaign,
          user: @player,
          action_values: { "Type" => "PC", "Fortune" => 2, "Wounds" => 0 },
          impairments: 0
        )
        @attacker_shot = Shot.create!(fight: @fight, character: @attacker, shot: 15)
        @defender_shot = Shot.create!(fight: @fight, character: @defender, shot: 12)
      end

      it "handles dodge defense (1 shot cost)" do
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
            shot: 11,  # Dodge costs 1 shot
            event: {
              type: "dodge",
              description: "Defender dodges"
            }
          },
          {
            shot_id: @defender_shot.id,
            character_id: @defender.id,
            action_values: { "Type" => "PC", "Wounds" => 4, "Fortune" => 2 },
            impairments: 0,
            event: {
              type: "attack",
              description: "Attacker attacked Defender (Dodge +3) for 4 wounds"
            }
          }
        ]

        post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
          params: { character_updates: character_updates },
          headers: @player_headers

        expect(response).to have_http_status(:ok)
        
        @defender_shot.reload
        @defender.reload
        expect(@defender_shot.shot).to eq(11)
        expect(@defender.action_values["Wounds"]).to eq(4)
      end

      it "handles fortune dodge (1 shot + 1 fortune)" do
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
            shot: 11,  # Fortune dodge costs 1 shot
            action_values: { "Type" => "PC", "Fortune" => 1, "Wounds" => 0 },  # And 1 fortune
            event: {
              type: "fortune_dodge",
              description: "Defender fortune dodges (roll: 5)"
            }
          },
          {
            shot_id: @defender_shot.id,
            character_id: @defender.id,
            action_values: { "Type" => "PC", "Wounds" => 2, "Fortune" => 1 },
            impairments: 0,
            event: {
              type: "attack",
              description: "Attacker attacked Defender (Fortune Dodge +5) for 2 wounds"
            }
          }
        ]

        post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
          params: { character_updates: character_updates },
          headers: @player_headers

        expect(response).to have_http_status(:ok)
        
        @defender_shot.reload
        @defender.reload
        expect(@defender_shot.shot).to eq(11)
        expect(@defender.action_values["Fortune"]).to eq(1)
        expect(@defender.action_values["Wounds"]).to eq(2)
      end
    end

    context "Multi-target attacks" do
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
          action_values: { "Type" => "Featured Foe" }
        )
        @target2 = Character.create!(
          name: "Thug 2",
          campaign: @campaign,
          action_values: { "Type" => "Featured Foe" }
        )
        @target3 = Character.create!(
          name: "Hero Ally",
          campaign: @campaign,
          user: @player,
          action_values: { "Type" => "PC", "Fortune" => 2, "Wounds" => 0 },
          impairments: 0
        )
        @attacker_shot = Shot.create!(fight: @fight, character: @attacker, shot: 15)
        @target1_shot = Shot.create!(fight: @fight, character: @target1, shot: 12, count: 0)
        @target2_shot = Shot.create!(fight: @fight, character: @target2, shot: 10, count: 0)
        @target3_shot = Shot.create!(fight: @fight, character: @target3, shot: 8)
      end

      it "handles attacking multiple targets with mixed defenses" do
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
            shot: 7,  # 8 - 1 for fortune dodge
            action_values: { "Type" => "PC", "Fortune" => 1, "Wounds" => 0 },  # Spent 1 fortune
            event: {
              type: "fortune_dodge",
              description: "Hero Ally fortune dodges (roll: 6)"
            }
          },
          {
            shot_id: @target3_shot.id,
            character_id: @target3.id,
            action_values: { "Type" => "PC", "Wounds" => 1, "Fortune" => 1 },
            impairments: 0,
            event: {
              type: "attack",
              description: "Jackie attacked Hero Ally (Fortune Dodge +6) for 1 wound"
            }
          }
        ]

        post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
          params: { character_updates: character_updates },
          headers: @gamemaster_headers

        expect(response).to have_http_status(:ok)
        
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
        expect(@target3.action_values["Wounds"]).to eq(1)
        expect(@target3.action_values["Fortune"]).to eq(1)
      end
    end

    context "Impairment thresholds" do
      context "PC crossing 30 and 35 wounds" do
        before do
          @pc = Character.create!(
            name: "Hero",
            campaign: @campaign,
            user: @player,
            action_values: { "Type" => "PC", "Wounds" => 28 },
            impairments: 0
          )
          @pc_shot = Shot.create!(fight: @fight, character: @pc, shot: 10)
        end

        it "adds 1 impairment when crossing 30 wounds" do
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

          post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
            params: { character_updates: character_updates },
            headers: @gamemaster_headers

          expect(response).to have_http_status(:ok)
          
          @pc.reload
          expect(@pc.action_values["Wounds"]).to eq(32)
          expect(@pc.impairments).to eq(1)
        end

        it "adds 2 impairments when crossing both 30 and 35 wounds" do
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

          post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
            params: { character_updates: character_updates },
            headers: @gamemaster_headers

          expect(response).to have_http_status(:ok)
          
          @pc.reload
          expect(@pc.action_values["Wounds"]).to eq(36)
          expect(@pc.impairments).to eq(2)
        end
      end

      context "Boss crossing 45 and 50 wounds" do
        before do
          @boss = Character.create!(
            name: "Big Boss",
            campaign: @campaign,
            action_values: { "Type" => "Boss" },
            impairments: 0
          )
          @boss_shot = Shot.create!(fight: @fight, character: @boss, shot: 10, count: 43)
        end

        it "adds 1 impairment when crossing 45 wounds" do
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

          post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
            params: { character_updates: character_updates },
            headers: @gamemaster_headers

          expect(response).to have_http_status(:ok)
          
          @boss_shot.reload
          expect(@boss_shot.count).to eq(47)
          expect(@boss_shot.impairments).to eq(1)
        end

        it "adds 2 impairments when crossing both 45 and 50 wounds" do
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

          post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
            params: { character_updates: character_updates },
            headers: @gamemaster_headers

          expect(response).to have_http_status(:ok)
          
          @boss_shot.reload
          expect(@boss_shot.count).to eq(52)
          expect(@boss_shot.impairments).to eq(2)
        end
      end
    end

    context "Mook scenarios" do
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

      it "reduces mook count when attacked" do
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
            count: 7,  # 3 mooks eliminated
            event: {
              type: "attack",
              description: "Hero took out 3 mooks"
            }
          }
        ]

        post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
          params: { character_updates: character_updates },
          headers: @gamemaster_headers

        expect(response).to have_http_status(:ok)
        
        @mook_shot.reload
        expect(@mook_shot.count).to eq(7)
      end

      it "handles total mook elimination" do
        @mook_shot.update!(count: 3)  # Start with only 3 mooks
        
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

        post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
          params: { character_updates: character_updates },
          headers: @gamemaster_headers

        expect(response).to have_http_status(:ok)
        
        @mook_shot.reload
        expect(@mook_shot.count).to eq(0)
      end
    end

    context "Fortune spending variations" do
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
          user: @player,
          action_values: { "Type" => "PC", "Fortune" => 1, "Wounds" => 0 },
          impairments: 0
        )
        @attacker_shot = Shot.create!(fight: @fight, character: @attacker, shot: 15)
        @defender_shot = Shot.create!(fight: @fight, character: @defender, shot: 12)
      end

      it "handles attacker spending fortune for extra damage" do
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

        post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
          params: { character_updates: character_updates },
          headers: @gamemaster_headers

        expect(response).to have_http_status(:ok)
        
        @attacker.reload
        @defender.reload
        expect(@attacker.action_values["Fortune"]).to eq(2)
        expect(@defender.action_values["Wounds"]).to eq(12)
      end

      it "handles defender with no fortune attempting regular defense" do
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

        post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
          params: { character_updates: character_updates },
          headers: @player_headers

        expect(response).to have_http_status(:ok)
        
        @defender.reload
        expect(@defender.action_values["Fortune"]).to eq(0)
        expect(@defender.action_values["Wounds"]).to eq(8)
      end
    end

    context "Error handling" do
      before do
        @character = Character.create!(
          name: "Test Character",
          campaign: @campaign,
          action_values: { "Type" => "PC", "Wounds" => 0 },
          impairments: 0
        )
        @shot = Shot.create!(fight: @fight, character: @character, shot: 3)
      end

      it "returns error for invalid character_id" do
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

        post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
          params: { character_updates: character_updates },
          headers: @gamemaster_headers

        expect(response).to have_http_status(:not_found)
        body = JSON.parse(response.body)
        expect(body["error"]).to include("Resource not found")
        
        @shot.reload
        expect(@shot.shot).to eq(3)  # Unchanged
      end

      it "returns error for invalid shot_id" do
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

        post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
          params: { character_updates: character_updates },
          headers: @gamemaster_headers

        expect(response).to have_http_status(:not_found)
        body = JSON.parse(response.body)
        expect(body["error"]).to include("Resource not found")
        
        @shot.reload
        expect(@shot.shot).to eq(3)  # Unchanged
      end

      it "returns error when no shot_id or character_id provided" do
        character_updates = [
          {
            shot: 0,
            event: {
              type: "act",
              description: "Missing IDs"
            }
          }
        ]

        post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
          params: { character_updates: character_updates },
          headers: @gamemaster_headers

        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]).to include("Must provide shot_id, character_id, or vehicle_id")
      end
    end

    context "Complex combat round" do
      it "handles complete multi-target attack with fortune and various defenses" do
        # Setup complex scenario
        @pc_attacker = Character.create!(
          name: "Master Fighter",
          campaign: @campaign,
          action_values: { "Type" => "PC", "Fortune" => 4, "Wounds" => 5, "MainAttack" => "Martial Arts", "Martial Arts" => 15 },
          impairments: 0
        )
        @boss = Character.create!(
          name: "Crime Boss",
          campaign: @campaign,
          action_values: { "Type" => "Boss" },
          impairments: 0
        )
        @featured_foe = Character.create!(
          name: "Lieutenant",
          campaign: @campaign,
          action_values: { "Type" => "Featured Foe" }
        )
        @mooks = Character.create!(
          name: "Thugs",
          campaign: @campaign,
          action_values: { "Type" => "Mook" }
        )
        @ally = Character.create!(
          name: "Sidekick",
          campaign: @campaign,
          user: @player,
          action_values: { "Type" => "PC", "Fortune" => 2, "Wounds" => 10 },
          impairments: 0
        )
        
        @attacker_shot = Shot.create!(fight: @fight, character: @pc_attacker, shot: 20)
        @boss_shot = Shot.create!(fight: @fight, character: @boss, shot: 18, count: 40)
        @foe_shot = Shot.create!(fight: @fight, character: @featured_foe, shot: 15, count: 5)
        @mook_shot = Shot.create!(fight: @fight, character: @mooks, shot: 12, count: 8)
        @ally_shot = Shot.create!(fight: @fight, character: @ally, shot: 10)
        
        character_updates = [
          # PC spends fortune and attacks multiple targets
          {
            shot_id: @attacker_shot.id,
            character_id: @pc_attacker.id,
            shot: 17,  # Spends 3 shots
            action_values: { "Type" => "PC", "Fortune" => 3, "Wounds" => 5 },  # Spent 1 fortune
            event: {
              type: "act",
              description: "Master Fighter acts with fortune (3 shots, 1 fortune)"
            }
          },
          # Boss takes damage, approaching impairment
          {
            shot_id: @boss_shot.id,
            character_id: @boss.id,
            wounds: 46,  # 40 + 6, crosses 45 threshold
            impairments: 1,
            event: {
              type: "attack",
              description: "Master Fighter attacked Crime Boss for 6 wounds (impairment!)"
            }
          },
          # Featured foe dodges
          {
            shot_id: @foe_shot.id,
            character_id: @featured_foe.id,
            shot: 14,  # Dodge costs 1 shot
            event: {
              type: "dodge",
              description: "Lieutenant dodges"
            }
          },
          {
            shot_id: @foe_shot.id,
            character_id: @featured_foe.id,
            wounds: 8,  # Takes reduced damage
            impairments: 0,
            event: {
              type: "attack",
              description: "Master Fighter attacked Lieutenant (Dodge +3) for 3 wounds"
            }
          },
          # Wipes out some mooks
          {
            shot_id: @mook_shot.id,
            character_id: @mooks.id,
            count: 4,  # 4 mooks eliminated
            event: {
              type: "attack",
              description: "Master Fighter took out 4 mooks"
            }
          },
          # Boss counter-attacks (2 shot cost)
          {
            shot_id: @boss_shot.id,
            character_id: @boss.id,
            shot: 16,  # Boss spends 2 shots
            event: {
              type: "act",
              description: "Crime Boss counter-attacks (2 shots)"
            }
          },
          # Ally fortune dodges
          {
            shot_id: @ally_shot.id,
            character_id: @ally.id,
            shot: 9,  # Fortune dodge costs 1 shot
            action_values: { "Type" => "PC", "Fortune" => 1, "Wounds" => 10 },  # Spent 1 fortune
            event: {
              type: "fortune_dodge",
              description: "Sidekick fortune dodges (roll: 5)"
            }
          },
          {
            shot_id: @ally_shot.id,
            character_id: @ally.id,
            action_values: { "Type" => "PC", "Fortune" => 1, "Wounds" => 33 },  # 10 + 23 damage, crosses 30
            impairments: 1,
            event: {
              type: "attack",
              description: "Crime Boss attacked Sidekick (Fortune Dodge +5) for 23 wounds (impairment!)"
            }
          }
        ]

        post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
          params: { character_updates: character_updates },
          headers: @gamemaster_headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["id"]).to eq(@fight.id)
        
        # Verify all complex state changes
        @attacker_shot.reload
        @pc_attacker.reload
        @boss_shot.reload
        @foe_shot.reload
        @mook_shot.reload
        @ally_shot.reload
        @ally.reload
        
        expect(@attacker_shot.shot).to eq(17)
        expect(@pc_attacker.action_values["Fortune"]).to eq(3)
        expect(@boss_shot.shot).to eq(16)
        expect(@boss_shot.count).to eq(46)
        expect(@boss_shot.impairments).to eq(1)
        expect(@foe_shot.shot).to eq(14)
        expect(@foe_shot.count).to eq(8)
        expect(@mook_shot.count).to eq(4)
        expect(@ally_shot.shot).to eq(9)
        expect(@ally.action_values["Fortune"]).to eq(1)
        expect(@ally.action_values["Wounds"]).to eq(33)
        expect(@ally.impairments).to eq(1)
      end
    end

    context "Vehicle combat" do
      before do
        @driver = Character.create!(
          name: "Driver",
          campaign: @campaign,
          user: @player,
          action_values: { "Type" => "PC", "Driving" => 14, "Wounds" => 0 },
          impairments: 0
        )
        @vehicle = Vehicle.create!(
          name: "Fast Car",
          campaign: @campaign,
          action_values: { "Acceleration" => 8, "Handling" => 10, "Frame" => 5 }
        )
        @driver_shot = Shot.create!(fight: @fight, character: @driver, shot: 15)
        @vehicle_shot = Shot.create!(fight: @fight, vehicle: @vehicle, shot: 15, driving_shot: @driver_shot)
      end

      it "handles vehicle taking damage" do
        character_updates = [
          {
            shot_id: @vehicle_shot.id,
            vehicle_id: @vehicle.id,
            shot: 12,  # Vehicle acts
            event: {
              type: "act",
              description: "Fast Car accelerates (3 shots)"
            }
          },
          {
            shot_id: @vehicle_shot.id,
            vehicle_id: @vehicle.id,
            wounds: 3,  # Vehicle takes damage
            event: {
              type: "attack",
              description: "Fast Car hit for 3 frame damage"
            }
          }
        ]

        post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
          params: { character_updates: character_updates },
          headers: @player_headers

        expect(response).to have_http_status(:ok)
        
        @vehicle_shot.reload
        expect(@vehicle_shot.shot).to eq(12)
        expect(@vehicle_shot.count).to eq(3)
      end
    end

    context "Player authorization" do
      before do
        @player_character = Character.create!(
          name: "Player Hero",
          campaign: @campaign,
          user: @player,
          action_values: { "Type" => "PC", "Wounds" => 0 },
          impairments: 0
        )
        @other_character = Character.create!(
          name: "GM NPC",
          campaign: @campaign,
          action_values: { "Type" => "PC", "Wounds" => 0 },
          impairments: 0
        )
        @player_shot = Shot.create!(fight: @fight, character: @player_character, shot: 10)
        @other_shot = Shot.create!(fight: @fight, character: @other_character, shot: 8)
      end

      it "allows player to update their own character" do
        character_updates = [
          {
            shot_id: @player_shot.id,
            character_id: @player_character.id,
            shot: 7,
            event: {
              type: "act",
              description: "Player Hero acts"
            }
          }
        ]

        post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
          params: { character_updates: character_updates },
          headers: @player_headers

        expect(response).to have_http_status(:ok)
        @player_shot.reload
        expect(@player_shot.shot).to eq(7)
      end

      it "allows gamemaster to update any character" do
        character_updates = [
          {
            shot_id: @other_shot.id,
            character_id: @other_character.id,
            shot: 5,
            event: {
              type: "act",
              description: "GM NPC acts"
            }
          }
        ]

        post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
          params: { character_updates: character_updates },
          headers: @gamemaster_headers

        expect(response).to have_http_status(:ok)
        @other_shot.reload
        expect(@other_shot.shot).to eq(5)
      end

      # Note: Current implementation doesn't restrict players from updating other characters
      # This could be added as a future authorization enhancement
    end

    context "Empty updates" do
      it "handles empty character_updates array" do
        post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
          params: { character_updates: [] },
          headers: @gamemaster_headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["id"]).to eq(@fight.id)
      end

      it "handles missing character_updates parameter" do
        post "/api/v2/encounters/#{@fight.id}/apply_combat_action",
          params: {},
          headers: @gamemaster_headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["id"]).to eq(@fight.id)
      end
    end
  end
end