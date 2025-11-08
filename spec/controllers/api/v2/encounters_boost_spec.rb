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
    sign_in gamemaster
  end

  describe "POST #apply_combat_action with boost" do
    let!(:booster_character) { campaign.characters.create!(name: "Booster Hero", action_values: { "Type" => "PC" }) }
    let!(:target_character) { campaign.characters.create!(name: "Target Hero", action_values: { "Type" => "PC" }) }
    let!(:booster_shot) { Shot.create!(fight: fight, character: booster_character, shot: 15) }
    let!(:target_shot) { Shot.create!(fight: fight, character: target_character, shot: 12) }

    before do
      # Set up PC characters with Fortune points
      booster_character.action_values["Fortune"] = 3
      booster_character.action_values["Max Fortune"] = 3
      booster_character.action_values["MainAttack"] = "Guns"
      booster_character.save!
      
      target_character.action_values["MainAttack"] = "Guns"
      target_character.save!
    end

    context "when boosting attack" do
      it "creates an attack boost without Fortune" do
        params = {
          id: fight.id,
          action_type: "boost",
          booster_id: booster_character.id,
          target_id: target_character.id,
          boost_type: "attack",
          use_fortune: false
        }

        expect {
          post :apply_combat_action, params: params
        }.to change(CharacterEffect, :count).by(1)

        booster_shot.reload
        expect(booster_shot.shot).to eq(12) # 15 - 3 = 12

        effect = CharacterEffect.last
        expect(effect.character_id).to eq(target_character.id)
        expect(effect.name).to eq("Attack Boost")
        expect(effect.action_value).to eq("Guns")
        expect(effect.change).to eq("+1")
        expect(effect.description).to include(booster_character.name)
      end

      it "creates an enhanced attack boost with Fortune" do
        params = {
          id: fight.id,
          action_type: "boost",
          booster_id: booster_character.id,
          target_id: target_character.id,
          boost_type: "attack",
          use_fortune: true
        }

        expect {
          post :apply_combat_action, params: params
        }.to change(CharacterEffect, :count).by(1)

        booster_shot.reload
        booster_character.reload
        expect(booster_shot.shot).to eq(12) # 15 - 3 = 12
        expect(booster_character.action_values["Fortune"]).to eq(2) # 3 - 1 = 2

        effect = CharacterEffect.last
        expect(effect.character_id).to eq(target_character.id)
        expect(effect.name).to eq("Attack Boost (Fortune)")
        expect(effect.action_value).to eq("Guns")
        expect(effect.change).to eq("+2")
        expect(effect.description).to include(booster_character.name)
      end
    end

    context "when boosting defense" do
      it "creates a defense boost without Fortune" do
        params = {
          id: fight.id,
          action_type: "boost",
          booster_id: booster_character.id,
          target_id: target_character.id,
          boost_type: "defense",
          use_fortune: false
        }

        expect {
          post :apply_combat_action, params: params
        }.to change(CharacterEffect, :count).by(1)

        booster_shot.reload
        expect(booster_shot.shot).to eq(12) # 15 - 3 = 12

        effect = CharacterEffect.last
        expect(effect.character_id).to eq(target_character.id)
        expect(effect.name).to eq("Defense Boost")
        expect(effect.action_value).to eq("Defense")
        expect(effect.change).to eq("+3")
        expect(effect.description).to include(booster_character.name)
      end

      it "creates an enhanced defense boost with Fortune" do
        params = {
          id: fight.id,
          action_type: "boost",
          booster_id: booster_character.id,
          target_id: target_character.id,
          boost_type: "defense",
          use_fortune: true
        }

        expect {
          post :apply_combat_action, params: params
        }.to change(CharacterEffect, :count).by(1)

        booster_shot.reload
        booster_character.reload
        expect(booster_shot.shot).to eq(12) # 15 - 3 = 12
        expect(booster_character.action_values["Fortune"]).to eq(2) # 3 - 1 = 2

        effect = CharacterEffect.last
        expect(effect.character_id).to eq(target_character.id)
        expect(effect.name).to eq("Defense Boost (Fortune)")
        expect(effect.action_value).to eq("Defense")
        expect(effect.change).to eq("+5")
        expect(effect.description).to include(booster_character.name)
      end
    end

    context "when NPC attempts to use Fortune" do
      let!(:npc_character) { campaign.characters.create!(name: "NPC Boss", action_values: { "Type" => "Featured Foe" }) }
      let!(:npc_shot) { Shot.create!(fight: fight, character: npc_character, shot: 15) }

      it "ignores Fortune flag for non-PC characters" do
        params = {
          id: fight.id,
          action_type: "boost",
          booster_id: npc_character.id,
          target_id: target_character.id,
          boost_type: "attack",
          use_fortune: true # This should be ignored for NPCs
        }

        post :apply_combat_action, params: params

        effect = CharacterEffect.last
        expect(effect.change).to eq("+1") # Standard boost, not enhanced
        expect(effect.name).to eq("Attack Boost") # No Fortune label
      end
    end

    context "with multiple boosts on same character" do
      before do
        # Create an existing attack boost
        CharacterEffect.create!(
          character: target_character,
          shot: target_shot,
          name: "Attack Boost",
          action_value: "Guns",
          change: "+1",
          description: "Boost from Another Hero",
          severity: "info"
        )
      end

      it "allows stacking multiple boosts" do
        params = {
          id: fight.id,
          action_type: "boost",
          booster_id: booster_character.id,
          target_id: target_character.id,
          boost_type: "attack",
          use_fortune: false
        }

        expect {
          post :apply_combat_action, params: params
        }.to change(CharacterEffect, :count).by(1)

        target_effects = CharacterEffect.where(character_id: target_character.id)
        expect(target_effects.count).to eq(2)
        # Both boosts should be +1 each (no Fortune used)
        expect(target_effects.pluck(:change)).to match_array(["+1", "+1"])
      end
    end

    context "with insufficient Fortune points" do
      before do
        booster_character.action_values["Fortune"] = 0
        booster_character.save!
      end

      it "fails when PC tries to use Fortune without points" do
        params = {
          id: fight.id,
          action_type: "boost",
          booster_id: booster_character.id,
          target_id: target_character.id,
          boost_type: "attack",
          use_fortune: true
        }

        post :apply_combat_action, params: params

        expect(response).to have_http_status(:unprocessable_content)
        expect(CharacterEffect.count).to eq(0)
      end
    end

  end
end