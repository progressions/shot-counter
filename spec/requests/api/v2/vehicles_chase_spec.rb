require 'rails_helper'

RSpec.describe "Api::V2::Vehicles Chase Actions", type: :request do
  let(:user) do
    User.create!(
      email: "test@example.com",
      first_name: "Test",
      last_name: "User",
      confirmed_at: Time.now,
      gamemaster: true
    )
  end
  
  let(:campaign) { user.campaigns.create!(name: "Test Campaign") }
  let(:fight) { campaign.fights.create!(name: "Test Fight") }
  let(:vehicle) do
    campaign.vehicles.create!(
      name: "Test Vehicle",
      action_values: {
        "Acceleration" => 10,
        "Handling" => 8,
        "Squeal" => 12,
        "Frame" => 7,
        "Crunch" => 9,
        "Chase Points" => 0,
        "Condition Points" => 0,
        "Position" => "far",
        "Pursuer" => "true"
      }
    )
  end
  let(:target_vehicle) do
    campaign.vehicles.create!(
      name: "Target Vehicle",
      action_values: {
        "Acceleration" => 8,
        "Handling" => 10,
        "Squeal" => 10,
        "Frame" => 8,
        "Crunch" => 8,
        "Chase Points" => 0,
        "Condition Points" => 0,
        "Position" => "far",
        "Pursuer" => "false"
      }
    )
  end
  
  before do
    @headers = Devise::JWT::TestHelpers.auth_headers({}, user)
    set_current_campaign(user, campaign)
  end

  describe "PATCH /api/v2/vehicles/:id/chase_state" do
    context "when updating chase points and position" do
      let(:chase_params) do
        {
          chase_state: {
            chase_points: 10,
            condition_points: 3,
            position: "near",
            pursuer: "true"
          }
        }
      end

      it "updates the vehicle's action_values with chase data" do
        patch "/api/v2/vehicles/#{vehicle.id}/chase_state", 
              params: chase_params, 
              headers: @headers

        expect(response).to have_http_status(:ok)
        
        vehicle.reload
        expect(vehicle.action_values["Chase Points"]).to eq(10)
        expect(vehicle.action_values["Condition Points"]).to eq(3)
        expect(vehicle.action_values["Position"]).to eq("near")
        expect(vehicle.action_values["Pursuer"]).to eq("true")
      end

      # Skipping broadcast tests - requires cable.yml test adapter configuration
      # it "broadcasts the update to the fight channel" do
      #   shot = fight.shots.create!(vehicle: vehicle, shot: 10)
      #   
      #   expect {
      #     patch "/api/v2/vehicles/#{vehicle.id}/chase_state", 
      #           params: chase_params, 
      #           headers: @headers
      #   }.to have_broadcasted_to("fight_#{fight.id}").with(hash_including("event" => "chase_update"))
      # end
    end

    context "with invalid position value" do
      let(:invalid_params) do
        {
          chase_state: {
            position: "invalid_position"
          }
        }
      end

      it "returns an error" do
        patch "/api/v2/vehicles/#{vehicle.id}/chase_state", 
              params: invalid_params, 
              headers: @headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Position must be 'near' or 'far'")
      end
    end

    context "with invalid chase points" do
      let(:invalid_params) do
        {
          chase_state: {
            chase_points: -5
          }
        }
      end

      it "returns an error" do
        patch "/api/v2/vehicles/#{vehicle.id}/chase_state", 
              params: invalid_params, 
              headers: @headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Chase points cannot be negative")
      end
    end

    context "when vehicle is not in a fight" do
      it "still updates chase state for preparation" do
        patch "/api/v2/vehicles/#{vehicle.id}/chase_state", 
              params: { chase_state: { chase_points: 5 } }, 
              headers: @headers

        expect(response).to have_http_status(:ok)
        expect(vehicle.reload.action_values["Chase Points"]).to eq(5)
      end
    end
  end

  describe "POST /api/v2/fights/:fight_id/shots/:id/assign_driver" do
    let(:character) do
      campaign.characters.create!(
        name: "Test Driver",
        action_values: { "Type" => "PC", "Driving" => 14 }
      )
    end
    let(:vehicle_shot) { fight.shots.create!(vehicle: vehicle, shot: 10) }
    let(:character_shot) { fight.shots.create!(character: character, shot: 10) }

    context "when assigning a driver to a vehicle" do
      let(:assign_params) do
        {
          driver_shot_id: character_shot.id
        }
      end

      it "creates the driver relationship" do
        post "/api/v2/fights/#{fight.id}/shots/#{vehicle_shot.id}/assign_driver", 
             params: assign_params, 
             headers: @headers

        expect(response).to have_http_status(:ok)
        
        character_shot.reload
        vehicle_shot.reload
        expect(character_shot.driving_id).to eq(vehicle_shot.id)
      end

      it "clears previous driver if one existed" do
        other_character = campaign.characters.create!(
          name: "Other Driver",
          action_values: { "Type" => "PC", "Driving" => 12 }
        )
        other_shot = fight.shots.create!(character: other_character, shot: 10, driving_id: vehicle_shot.id)

        post "/api/v2/fights/#{fight.id}/shots/#{vehicle_shot.id}/assign_driver", 
             params: assign_params, 
             headers: @headers

        expect(response).to have_http_status(:ok)
        
        other_shot.reload
        expect(other_shot.driving_id).to be_nil
        expect(character_shot.reload.driving_id).to eq(vehicle_shot.id)
      end

      # Skipping broadcast tests - requires cable.yml test adapter configuration
      # it "broadcasts the update to the fight channel" do
      #   expect {
      #     post "/api/v2/fights/#{fight.id}/shots/#{vehicle_shot.id}/assign_driver", 
      #          params: assign_params, 
      #          headers: @headers
      #   }.to have_broadcasted_to("fight_#{fight.id}")
      # end
    end

    context "with invalid driver shot" do
      it "returns an error when driver shot doesn't exist" do
        post "/api/v2/fights/#{fight.id}/shots/#{vehicle_shot.id}/assign_driver", 
             params: { driver_shot_id: "00000000-0000-0000-0000-000000000000" }, 
             headers: @headers

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to include("Driver shot not found")
      end

      it "returns an error when driver shot has no character" do
        empty_vehicle = campaign.vehicles.create!(name: "Empty Vehicle")
        empty_shot = fight.shots.create!(vehicle: empty_vehicle, shot: 10)
        
        post "/api/v2/fights/#{fight.id}/shots/#{vehicle_shot.id}/assign_driver", 
             params: { driver_shot_id: empty_shot.id }, 
             headers: @headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to include("Shot must contain a character to be a driver")
      end
    end
  end

  describe "DELETE /api/v2/fights/:fight_id/shots/:id/remove_driver" do
    let(:character) do
      campaign.characters.create!(
        name: "Test Driver",
        action_values: { "Type" => "PC", "Driving" => 14 }
      )
    end
    let(:vehicle_shot) { fight.shots.create!(vehicle: vehicle, shot: 10) }
    let(:character_shot) { fight.shots.create!(character: character, shot: 10, driving_id: vehicle_shot.id) }

    before do
      character_shot # ensure it exists and is linked
    end

    it "removes the driver relationship" do
      delete "/api/v2/fights/#{fight.id}/shots/#{vehicle_shot.id}/remove_driver", 
             headers: @headers

      expect(response).to have_http_status(:ok)
      
      character_shot.reload
      expect(character_shot.driving_id).to be_nil
    end

    # Skipping broadcast tests - requires cable.yml test adapter configuration
    # it "broadcasts the update to the fight channel" do
    #   expect {
    #     delete "/api/v2/fights/#{fight.id}/shots/#{vehicle_shot.id}/remove_driver", 
    #            headers: @headers
    #   }.to have_broadcasted_to("fight_#{fight.id}")
    # end

    context "when no driver exists" do
      let(:vehicle_shot_no_driver) do
        no_driver_vehicle = campaign.vehicles.create!(name: "No Driver Vehicle")
        fight.shots.create!(vehicle: no_driver_vehicle, shot: 10)
      end

      it "returns success anyway" do
        delete "/api/v2/fights/#{fight.id}/shots/#{vehicle_shot_no_driver.id}/remove_driver", 
               headers: @headers

        expect(response).to have_http_status(:ok)
      end
    end
  end
end