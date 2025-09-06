require 'rails_helper'

RSpec.describe Api::V2::EncountersController, type: :controller do
  include Devise::Test::ControllerHelpers
  
  let!(:gamemaster) { User.create!(email: "gm@example.com", first_name: "Game", last_name: "Master", confirmed_at: Time.now, password: "password123", gamemaster: true) }
  let!(:player) { User.create!(email: "player@example.com", first_name: "Player", last_name: "One", confirmed_at: Time.now, password: "password123") }
  let!(:campaign) { gamemaster.campaigns.create!(name: "Test Campaign") }
  let!(:fight) { campaign.fights.create!(name: "Test Fight") }
  
  before do
    gamemaster.campaign_ids = [campaign.id]
    gamemaster.save!
    player.campaign_ids = [campaign.id]
    player.save!
    allow_any_instance_of(ApplicationController).to receive(:current_campaign).and_return(campaign)
    sign_in player
  end

  describe "POST #apply_combat_action with up_check" do
    let!(:pc_character) { 
      campaign.characters.create!(
        name: "Wounded Hero", 
        user: player,
        action_values: { 
          "Type" => "PC", 
          "Wounds" => 36,
          "Toughness" => 2,
          "Fortune" => 3,
          "Marks of Death" => 1
        },
        status: ["up_check_required"]
      ) 
    }
    let!(:pc_shot) { Shot.create!(fight: fight, character: pc_character, shot: 10) }

    context "when making a successful Up Check" do
      it "removes up_check_required status" do
        params = {
          id: fight.id,
          action_type: "up_check",
          character_id: pc_character.id,
          swerve: 3,
          fortune: 0
        }

        post :apply_combat_action, params: params

        expect(response).to have_http_status(:ok)
        
        pc_character.reload
        expect(pc_character.status).not_to include("up_check_required")
        expect(pc_character.status).not_to include("out_of_fight")
      end

      it "increments Marks of Death" do
        initial_marks = pc_character.action_values["Marks of Death"]
        
        params = {
          id: fight.id,
          action_type: "up_check",
          character_id: pc_character.id,
          swerve: 3,
          fortune: 0
        }

        post :apply_combat_action, params: params

        pc_character.reload
        expect(pc_character.action_values["Marks of Death"]).to eq(initial_marks + 1)
      end

      it "creates a fight event" do
        params = {
          id: fight.id,
          action_type: "up_check",
          character_id: pc_character.id,
          swerve: 3,
          fortune: 0
        }

        expect {
          post :apply_combat_action, params: params
        }.to change(fight.fight_events, :count).by(1)

        event = fight.fight_events.last
        expect(event.event_type).to eq("up_check")
        expect(event.description).to include("succeeded")
      end
    end

    context "when making a failed Up Check" do
      it "sets status to out_of_fight" do
        params = {
          id: fight.id,
          action_type: "up_check",
          character_id: pc_character.id,
          swerve: 1,  # 1 + 2 (Toughness) = 3, which is < 5
          fortune: 0
        }

        post :apply_combat_action, params: params

        expect(response).to have_http_status(:ok)
        
        pc_character.reload
        expect(pc_character.status).to eq(["out_of_fight"])
      end

      it "creates a fight event with failure message" do
        params = {
          id: fight.id,
          action_type: "up_check",
          character_id: pc_character.id,
          swerve: 1,
          fortune: 0
        }

        post :apply_combat_action, params: params

        event = fight.fight_events.last
        expect(event.event_type).to eq("up_check")
        expect(event.description).to include("failed")
        expect(event.details["passed"]).to be false
      end
    end

    context "when using Fortune die" do
      it "deducts Fortune point and adds extra Mark of Death" do
        initial_fortune = pc_character.action_values["Fortune"]
        initial_marks = pc_character.action_values["Marks of Death"]
        
        params = {
          id: fight.id,
          action_type: "up_check",
          character_id: pc_character.id,
          swerve: 2,
          fortune: 2
        }

        post :apply_combat_action, params: params

        pc_character.reload
        expect(pc_character.action_values["Fortune"]).to eq(initial_fortune - 1)
        expect(pc_character.action_values["Marks of Death"]).to eq(initial_marks + 2) # One for check, one for Fortune
      end

      it "returns error if insufficient Fortune points" do
        pc_character.action_values["Fortune"] = 0
        pc_character.save!
        
        params = {
          id: fight.id,
          action_type: "up_check",
          character_id: pc_character.id,
          swerve: 2,
          fortune: 2
        }

        post :apply_combat_action, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to include("Insufficient Fortune")
      end
    end

    context "validation errors" do
      it "returns error if character doesn't require Up Check" do
        pc_character.update!(status: [])
        
        params = {
          id: fight.id,
          action_type: "up_check",
          character_id: pc_character.id,
          swerve: 3,
          fortune: 0
        }

        post :apply_combat_action, params: params

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["error"]).to include("does not require an Up Check")
      end

      it "returns error if character is not a PC" do
        npc = campaign.characters.create!(
          name: "NPC",
          action_values: { "Type" => "Featured Foe" },
          status: ["up_check_required"]
        )
        Shot.create!(fight: fight, character: npc, shot: 5)
        
        params = {
          id: fight.id,
          action_type: "up_check",
          character_id: npc.id,
          swerve: 3,
          fortune: 0
        }

        post :apply_combat_action, params: params

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["error"]).to include("Only PCs can make Up Checks")
      end

      it "returns error if character not in fight" do
        other_character = campaign.characters.create!(
          name: "Other PC",
          action_values: { "Type" => "PC" },
          status: ["up_check_required"]
        )
        
        params = {
          id: fight.id,
          action_type: "up_check",
          character_id: other_character.id,
          swerve: 3,
          fortune: 0
        }

        post :apply_combat_action, params: params

        expect(response).to have_http_status(:not_found)
      end
    end

    context "authorization" do
      it "allows player to make Up Check for their own character" do
        params = {
          id: fight.id,
          action_type: "up_check",
          character_id: pc_character.id,
          swerve: 3,
          fortune: 0
        }

        post :apply_combat_action, params: params
        expect(response).to have_http_status(:ok)
      end

      it "allows gamemaster to make Up Check for any PC" do
        sign_out player
        sign_in gamemaster
        
        params = {
          id: fight.id,
          action_type: "up_check",
          character_id: pc_character.id,
          swerve: 3,
          fortune: 0
        }

        post :apply_combat_action, params: params
        expect(response).to have_http_status(:ok)
      end
    end
  end
end