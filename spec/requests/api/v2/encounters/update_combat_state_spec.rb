require "rails_helper"

RSpec.describe "Api::V2::Encounters - Update Combat State", type: :request do
  before(:each) do
    # Create users
    @gamemaster = User.create!(
      email: "gamemaster@example.com", 
      first_name: "Game", 
      last_name: "Master", 
      confirmed_at: Time.now, 
      gamemaster: true,
      password: "password123"
    )
    @player = User.create!(
      email: "player@example.com", 
      confirmed_at: Time.now, 
      gamemaster: false, 
      first_name: "Player", 
      last_name: "One",
      password: "password123"
    )

    # Create campaign
    @campaign = @gamemaster.campaigns.create!(name: "Test Campaign")
    
    # Create fight
    @fight = @campaign.fights.create!(name: "Test Fight")
    
    # Create characters of different types
    @pc_character = Character.create!(
      name: "Hero PC",
      action_values: { 
        "Type" => "PC", 
        "Wounds" => 0,
        "MainAttack" => "Martial Arts",
        "Martial Arts" => 15,
        "Defense" => 13
      },
      impairments: 0,
      campaign_id: @campaign.id,
      user_id: @player.id
    )
    
    @npc_character = Character.create!(
      name: "Enemy NPC",
      action_values: { 
        "Type" => "Featured Foe",
        "MainAttack" => "Martial Arts",
        "Martial Arts" => 14,
        "Defense" => 12
      },
      campaign_id: @campaign.id,
      user_id: @gamemaster.id
    )
    
    @boss_character = Character.create!(
      name: "Big Boss",
      action_values: { 
        "Type" => "Boss",
        "MainAttack" => "Martial Arts",
        "Martial Arts" => 16,
        "Defense" => 14
      },
      campaign_id: @campaign.id,
      user_id: @gamemaster.id
    )
    
    @mook_character = Character.create!(
      name: "Mook Squad",
      action_values: { 
        "Type" => "Mook",
        "Damage" => 7
      },
      campaign_id: @campaign.id,
      user_id: @gamemaster.id
    )
    
    # Create shots for the fight
    @pc_shot = @fight.shots.create!(
      character: @pc_character,
      shot: 10,
      count: 0,
      impairments: 0
    )
    
    @npc_shot = @fight.shots.create!(
      character: @npc_character,
      shot: 8,
      count: 0,
      impairments: 0
    )
    
    @boss_shot = @fight.shots.create!(
      character: @boss_character,
      shot: 12,
      count: 0,
      impairments: 0
    )
    
    @mook_shot = @fight.shots.create!(
      character: @mook_character,
      shot: 5,
      count: 10,  # 10 mooks in the squad
      impairments: 0
    )
    
    # Set up authentication
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end

  describe "POST /api/v2/encounters/:id/update_combat_state" do
    context "when updating a PC character" do
      it "updates wounds and impairments on the character record" do
        post "/api/v2/encounters/#{@fight.id}/update_combat_state", 
          params: {
            shot_id: @pc_shot.id,
            wounds: 25,
            impairments: 1,
            event: {
              type: "attack",
              description: "Hero PC took damage from Boss",
              details: {
                damage: 25,
                attacker: "Big Boss"
              }
            }
          },
          headers: @headers
        
        expect(response).to have_http_status(:success)
        
        # Check that PC character was updated (persistent)
        @pc_character.reload
        expect(@pc_character.action_values["Wounds"]).to eq(25)
        expect(@pc_character.impairments).to eq(1)
        
        # Check that shot was NOT updated for wounds (PC wounds are on character)
        @pc_shot.reload
        expect(@pc_shot.count).to eq(0)
        
        # Check fight event was created
        event = @fight.fight_events.last
        expect(event.event_type).to eq("attack")
        expect(event.description).to eq("Hero PC took damage from Boss")
        expect(event.details["damage"]).to eq("25")  # JSON params come in as strings
      end
      
      it "handles PC healing by reducing wounds" do
        # First give the PC some wounds
        @pc_character.update!(
          action_values: @pc_character.action_values.merge("Wounds" => 30),
          impairments: 2
        )
        
        post "/api/v2/encounters/#{@fight.id}/update_combat_state", 
          params: {
            shot_id: @pc_shot.id,
            wounds: 10,  # Healed from 30 to 10
            impairments: 0,
            event: {
              type: "heal",
              description: "Hero PC was healed",
              details: {
                healing: 20,
                source: "Medicine check"
              }
            }
          },
          headers: @headers
        
        expect(response).to have_http_status(:success)
        
        @pc_character.reload
        expect(@pc_character.action_values["Wounds"]).to eq(10)
        expect(@pc_character.impairments).to eq(0)
      end
    end
    
    context "when updating an NPC character" do
      it "updates count and impairments on the shot record" do
        post "/api/v2/encounters/#{@fight.id}/update_combat_state", 
          params: {
            shot_id: @npc_shot.id,
            count: 15,  # NPC wounds stored in count
            impairments: 1,
            event: {
              type: "attack",
              description: "Enemy NPC took damage",
              details: {
                damage: 15,
                attacker: "Hero PC"
              }
            }
          },
          headers: @headers
        
        expect(response).to have_http_status(:success)
        
        # Check that shot was updated (fight-specific)
        @npc_shot.reload
        expect(@npc_shot.count).to eq(15)
        expect(@npc_shot.impairments).to eq(1)
        
        # Check that character was NOT updated (NPC wounds are on shot)
        @npc_character.reload
        expect(@npc_character.action_values["Wounds"]).to eq(0)  # Default value
        # NPCs don't have impairments on character model - it's on the shot
      end
    end
    
    context "when updating a Boss character" do
      it "updates count with higher wound thresholds in mind" do
        post "/api/v2/encounters/#{@fight.id}/update_combat_state", 
          params: {
            shot_id: @boss_shot.id,
            count: 45,  # Boss gets impairment at 40-45
            impairments: 1,
            event: {
              type: "attack",
              description: "Big Boss took major damage",
              details: {
                damage: 45,
                attacker: "Hero PC",
                critical: true
              }
            }
          },
          headers: @headers
        
        expect(response).to have_http_status(:success)
        
        @boss_shot.reload
        expect(@boss_shot.count).to eq(45)
        expect(@boss_shot.impairments).to eq(1)
      end
    end
    
    context "when updating Mooks" do
      it "updates count as the number of mooks remaining" do
        post "/api/v2/encounters/#{@fight.id}/update_combat_state", 
          params: {
            shot_id: @mook_shot.id,
            count: 7,  # 3 mooks eliminated, 7 remaining
            impairments: 0,  # Mooks don't have impairments
            event: {
              type: "attack",
              description: "3 mooks were taken out",
              details: {
                mooks_eliminated: 3,
                attacker: "Hero PC"
              }
            }
          },
          headers: @headers
        
        expect(response).to have_http_status(:success)
        
        @mook_shot.reload
        expect(@mook_shot.count).to eq(7)
        expect(@mook_shot.impairments).to eq(0)
      end
      
      it "can eliminate all mooks" do
        post "/api/v2/encounters/#{@fight.id}/update_combat_state", 
          params: {
            shot_id: @mook_shot.id,
            count: 0,  # All mooks eliminated
            impairments: 0,
            event: {
              type: "attack",
              description: "All mooks were defeated",
              details: {
                mooks_eliminated: 10,
                attacker: "Hero PC",
                attack_type: "area_effect"
              }
            }
          },
          headers: @headers
        
        expect(response).to have_http_status(:success)
        
        @mook_shot.reload
        expect(@mook_shot.count).to eq(0)
      end
    end
    
    context "when event data is not provided" do
      it "still updates combat state without creating an event" do
        initial_event_count = @fight.fight_events.count
        
        post "/api/v2/encounters/#{@fight.id}/update_combat_state", 
          params: {
            shot_id: @npc_shot.id,
            count: 5,
            impairments: 0
          },
          headers: @headers
        
        expect(response).to have_http_status(:success)
        
        @npc_shot.reload
        expect(@npc_shot.count).to eq(5)
        expect(@fight.fight_events.count).to eq(initial_event_count)
      end
    end
    
    context "with invalid shot_id" do
      it "returns not found error" do
        post "/api/v2/encounters/#{@fight.id}/update_combat_state", 
          params: {
            shot_id: "invalid-uuid",
            count: 10,
            impairments: 1
          },
          headers: @headers
        
        expect(response).to have_http_status(:not_found)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Shot not found")
      end
    end
    
    context "without authentication" do
      it "returns unauthorized" do
        post "/api/v2/encounters/#{@fight.id}/update_combat_state", 
          params: {
            shot_id: @pc_shot.id,
            wounds: 10,
            impairments: 0
          }
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
    
    context "when fight doesn't belong to current campaign" do
      it "returns not found" do
        other_campaign = @gamemaster.campaigns.create!(name: "Other Campaign")
        other_fight = other_campaign.fights.create!(name: "Other Fight")
        
        post "/api/v2/encounters/#{other_fight.id}/update_combat_state", 
          params: {
            shot_id: @pc_shot.id,
            wounds: 10,
            impairments: 0
          },
          headers: @headers
        
        expect(response).to have_http_status(:not_found)
      end
    end
    
    context "response format" do
      it "returns the updated encounter in the response" do
        post "/api/v2/encounters/#{@fight.id}/update_combat_state", 
          params: {
            shot_id: @pc_shot.id,
            wounds: 5,
            impairments: 0
          },
          headers: @headers
        
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        
        # Check that response includes encounter data
        expect(body["id"]).to eq(@fight.id)
        expect(body["name"]).to eq("Test Fight")
        expect(body["shots"]).to be_an(Array)
        
        # Find the shot group that contains our character
        shot_group = body["shots"].find { |s| s["shot"] == @pc_shot.shot }
        expect(shot_group).not_to be_nil
        
        # Find our character in that shot group
        character = shot_group["characters"].find { |c| c["id"] == @pc_character.id }
        expect(character).not_to be_nil
        expect(character["name"]).to eq("Hero PC")
      end
    end
    
    context "ActionCable broadcasting" do
      it "updates the fight's updated_at timestamp to trigger broadcasts" do
        original_updated_at = @fight.updated_at
        
        post "/api/v2/encounters/#{@fight.id}/update_combat_state", 
          params: {
            shot_id: @pc_shot.id,
            wounds: 10,
            impairments: 0
          },
          headers: @headers
        
        expect(response).to have_http_status(:success)
        
        @fight.reload
        expect(@fight.updated_at).to be > original_updated_at
      end
    end
  end
end