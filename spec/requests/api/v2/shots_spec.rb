require "rails_helper"

RSpec.describe "Api::V2::Shots", type: :request do
  before(:each) do
    # Create users
    @gamemaster = User.create!(
      email: "gamemaster@example.com", 
      first_name: "Game", 
      last_name: "Master", 
      confirmed_at: Time.now, 
      gamemaster: true
    )
    @player = User.create!(
      email: "player@example.com",
      first_name: "Player",
      last_name: "One",
      confirmed_at: Time.now,
      gamemaster: false
    )
    
    # Create campaign and fight
    @campaign = @gamemaster.campaigns.create!(name: "Test Campaign")
    @fight = @campaign.fights.create!(name: "Test Fight", description: "A test battle")
    
    # Create different character types
    @pc = @campaign.characters.create!(
      name: "Hero PC",
      action_values: { 
        "Type" => "PC", 
        "Archetype" => "Everyday Hero",
        "Wounds" => 0,
        "Marks of Death" => 0
      },
      user_id: @player.id,
      impairments: 0
    )
    
    @boss = @campaign.characters.create!(
      name: "Big Boss",
      action_values: { "Type" => "Boss", "Marks of Death" => 0 },
      user_id: @gamemaster.id
    )
    
    @featured_foe = @campaign.characters.create!(
      name: "Tough Guy",
      action_values: { "Type" => "Featured Foe", "Marks of Death" => 0 },
      user_id: @gamemaster.id
    )
    
    @mook = @campaign.characters.create!(
      name: "Mook Squad",
      action_values: { "Type" => "Mook" },
      user_id: @gamemaster.id
    )
    
    @ally = @campaign.characters.create!(
      name: "Helper",
      action_values: { "Type" => "Ally" },
      user_id: @gamemaster.id
    )
    
    @uber_boss = @campaign.characters.create!(
      name: "Ultimate Evil",
      action_values: { "Type" => "Uber-Boss", "Marks of Death" => 0 },
      user_id: @gamemaster.id
    )
    
    # Add characters to fight with initial shot data
    @pc_shot = @fight.shots.create!(character: @pc, shot: 10)
    @boss_shot = @fight.shots.create!(character: @boss, shot: 8, count: 50, impairments: 0)
    @featured_foe_shot = @fight.shots.create!(character: @featured_foe, shot: 6, count: 35, impairments: 1)
    @mook_shot = @fight.shots.create!(character: @mook, shot: 4, count: 10)
    @ally_shot = @fight.shots.create!(character: @ally, shot: 3, count: 25, impairments: 0)
    @uber_boss_shot = @fight.shots.create!(character: @uber_boss, shot: 15, count: 70, impairments: 0)
    
    # Set up headers and campaign context
    @gamemaster_headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    @player_headers = Devise::JWT::TestHelpers.auth_headers({}, @player)
    set_current_campaign(@gamemaster, @campaign)
    set_current_campaign(@player, @campaign)
    Rails.cache.clear
  end

  describe "PATCH /api/v2/fights/:fight_id/shots/:id" do
    context "when user is gamemaster" do
      context "updating shot position" do
        it "updates the current shot value" do
          patch "/api/v2/fights/#{@fight.id}/shots/#{@pc_shot.id}", 
            params: { shot: { shot: 15 } }, 
            headers: @gamemaster_headers
          
          expect(response).to have_http_status(:success)
          body = JSON.parse(response.body)
          expect(body["success"]).to eq(true)
          
          @pc_shot.reload
          expect(@pc_shot.shot).to eq(15)
        end
        
        it "allows setting shot to null (hidden)" do
          patch "/api/v2/fights/#{@fight.id}/shots/#{@boss_shot.id}", 
            params: { shot: { shot: nil } }, 
            headers: @gamemaster_headers
          
          expect(response).to have_http_status(:success)
          @boss_shot.reload
          expect(@boss_shot.shot).to be_nil
        end
        
        it "allows setting shot to 0" do
          patch "/api/v2/fights/#{@fight.id}/shots/#{@featured_foe_shot.id}", 
            params: { shot: { shot: 0 } }, 
            headers: @gamemaster_headers
          
          expect(response).to have_http_status(:success)
          @featured_foe_shot.reload
          expect(@featured_foe_shot.shot).to eq(0)
        end
      end
    
      context "updating non-PC wounds and impairments" do
        it "updates count for a Featured Foe" do
          patch "/api/v2/fights/#{@fight.id}/shots/#{@featured_foe_shot.id}", 
            params: { shot: { count: 34 } }, 
            headers: @gamemaster_headers
          
          expect(response).to have_http_status(:success)
          @featured_foe_shot.reload
          expect(@featured_foe_shot.count).to eq(34)
        end
        
        it "updates count and impairments for a Boss" do
          patch "/api/v2/fights/#{@fight.id}/shots/#{@boss_shot.id}", 
            params: { 
              shot: { 
                count: 45,
                impairments: 2
              } 
            }, 
            headers: @gamemaster_headers
          
          expect(response).to have_http_status(:success)
          @boss_shot.reload
          expect(@boss_shot.count).to eq(45)
          expect(@boss_shot.impairments).to eq(2)
        end
        
        it "updates count for Mooks" do
          patch "/api/v2/fights/#{@fight.id}/shots/#{@mook_shot.id}", 
            params: { shot: { count: 5 } }, 
            headers: @gamemaster_headers
          
          expect(response).to have_http_status(:success)
          @mook_shot.reload
          expect(@mook_shot.count).to eq(5)
        end
        
        it "updates count for an Ally" do
          patch "/api/v2/fights/#{@fight.id}/shots/#{@ally_shot.id}", 
            params: { shot: { count: 20 } }, 
            headers: @gamemaster_headers
          
          expect(response).to have_http_status(:success)
          @ally_shot.reload
          expect(@ally_shot.count).to eq(20)
        end
        
        it "updates count and impairments for an Uber-Boss" do
          patch "/api/v2/fights/#{@fight.id}/shots/#{@uber_boss_shot.id}", 
            params: { 
              shot: { 
                count: 65,
                impairments: 1
              } 
            }, 
            headers: @gamemaster_headers
          
          expect(response).to have_http_status(:success)
          @uber_boss_shot.reload
          expect(@uber_boss_shot.count).to eq(65)
          expect(@uber_boss_shot.impairments).to eq(1)
        end
        
        it "updates all shot fields together" do
          patch "/api/v2/fights/#{@fight.id}/shots/#{@featured_foe_shot.id}", 
            params: { 
              shot: { 
                shot: 12,
                count: 30,
                impairments: 3,
                location: "Behind cover"
              } 
            }, 
            headers: @gamemaster_headers
          
          expect(response).to have_http_status(:success)
          @featured_foe_shot.reload
          expect(@featured_foe_shot.shot).to eq(12)
          expect(@featured_foe_shot.count).to eq(30)
          expect(@featured_foe_shot.impairments).to eq(3)
          expect(@featured_foe_shot.location).to eq("Behind cover")
        end
        
        it "does not affect the character's base count field" do
          original_char_count = @boss.count
          
          patch "/api/v2/fights/#{@fight.id}/shots/#{@boss_shot.id}", 
            params: { shot: { count: 38 } }, 
            headers: @gamemaster_headers
          
          expect(response).to have_http_status(:success)
          @boss_shot.reload
          expect(@boss_shot.count).to eq(38)
          
          @boss.reload
          expect(@boss.count).to eq(original_char_count) # Character's count unchanged
        end
      end
    
      context "location updates" do
        it "updates the location field" do
          patch "/api/v2/fights/#{@fight.id}/shots/#{@pc_shot.id}", 
            params: { shot: { location: "On the roof" } }, 
            headers: @gamemaster_headers
          
          expect(response).to have_http_status(:success)
          @pc_shot.reload
          expect(@pc_shot.location).to eq("On the roof")
        end
        
        it "clears the location when set to empty string" do
          @pc_shot.update!(location: "Starting position")
          
          patch "/api/v2/fights/#{@fight.id}/shots/#{@pc_shot.id}", 
            params: { shot: { location: "" } }, 
            headers: @gamemaster_headers
          
          expect(response).to have_http_status(:success)
          @pc_shot.reload
          expect(@pc_shot.location).to eq("")
        end
      end
      
      context "error handling" do
        it "returns 404 for non-existent shot" do
          patch "/api/v2/fights/#{@fight.id}/shots/99999", 
            params: { shot: { shot: 10 } }, 
            headers: @gamemaster_headers
          
          expect(response).to have_http_status(:not_found)
        end
        
        it "returns 404 for shot from different fight" do
          other_fight = @campaign.fights.create!(name: "Other Fight")
          other_shot = other_fight.shots.create!(character: @pc, shot: 5)
          
          patch "/api/v2/fights/#{@fight.id}/shots/#{other_shot.id}", 
            params: { shot: { shot: 10 } }, 
            headers: @gamemaster_headers
          
          expect(response).to have_http_status(:not_found)
        end
        
        it "returns 401 for unauthenticated requests" do
          patch "/api/v2/fights/#{@fight.id}/shots/#{@pc_shot.id}", 
            params: { shot: { shot: 10 } }
          
          expect(response).to have_http_status(:unauthorized)
        end
      end
      
      context "broadcast updates" do
        it "triggers encounter broadcast after update" do
          expect_any_instance_of(Fight).to receive(:broadcast_encounter_update!)
          
          patch "/api/v2/fights/#{@fight.id}/shots/#{@pc_shot.id}", 
            params: { shot: { shot: 20 } }, 
            headers: @gamemaster_headers
        end
        
        it "touches the fight to update timestamp" do
          original_updated_at = @fight.updated_at
          
          sleep 0.1 # Ensure time difference
          patch "/api/v2/fights/#{@fight.id}/shots/#{@pc_shot.id}", 
            params: { shot: { shot: 20 } }, 
            headers: @gamemaster_headers
          
          @fight.reload
          expect(@fight.updated_at).to be > original_updated_at
        end
      end
    end
    
    context "when user is a player" do
      it "allows updating their own character's shot" do
        patch "/api/v2/fights/#{@fight.id}/shots/#{@pc_shot.id}", 
          params: { shot: { shot: 12 } }, 
          headers: @player_headers
        
        expect(response).to have_http_status(:success)
        @pc_shot.reload
        expect(@pc_shot.shot).to eq(12)
      end
      
      it "allows updating gamemaster's character shot" do
        patch "/api/v2/fights/#{@fight.id}/shots/#{@boss_shot.id}", 
          params: { shot: { count: 40 } }, 
          headers: @player_headers
        
        expect(response).to have_http_status(:success)
        @boss_shot.reload
        expect(@boss_shot.count).to eq(40)
      end
    end
  end
  
  describe "DELETE /api/v2/fights/:fight_id/shots/:id" do
    context "when user is gamemaster" do
      it "removes the shot from the fight" do
        expect {
          delete "/api/v2/fights/#{@fight.id}/shots/#{@pc_shot.id}", 
            headers: @gamemaster_headers
        }.to change(Shot, :count).by(-1)
        
        expect(response).to have_http_status(:no_content)
        expect(Shot.find_by(id: @pc_shot.id)).to be_nil
      end
      
      it "triggers encounter broadcast after deletion" do
        expect_any_instance_of(Fight).to receive(:broadcast_encounter_update!)
        
        delete "/api/v2/fights/#{@fight.id}/shots/#{@pc_shot.id}", 
          headers: @gamemaster_headers
      end
      
      it "returns 404 for non-existent shot" do
        delete "/api/v2/fights/#{@fight.id}/shots/99999", 
          headers: @gamemaster_headers
        
        expect(response).to have_http_status(:not_found)
      end
      
      it "returns 404 for shot from different fight" do
        other_fight = @campaign.fights.create!(name: "Other Fight")
        other_shot = other_fight.shots.create!(character: @pc, shot: 5)
        
        delete "/api/v2/fights/#{@fight.id}/shots/#{other_shot.id}", 
          headers: @gamemaster_headers
        
        expect(response).to have_http_status(:not_found)
      end
    end
    
    context "when user is player" do
      it "allows removing shots" do
        expect {
          delete "/api/v2/fights/#{@fight.id}/shots/#{@boss_shot.id}", 
            headers: @player_headers
        }.to change(Shot, :count).by(-1)
        
        expect(response).to have_http_status(:no_content)
      end
    end
    
    context "when user is unauthenticated" do
      it "returns 401" do
        delete "/api/v2/fights/#{@fight.id}/shots/#{@pc_shot.id}"
        
        expect(response).to have_http_status(:unauthorized)
        expect(Shot.find_by(id: @pc_shot.id)).to be_present
      end
    end
  end
end