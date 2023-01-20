require 'rails_helper'

RSpec.describe "CharacterEffects", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com")
    @campaign = @gamemaster.campaigns.create!(title: "Adventure")
    @fight = @campaign.fights.create!(name: "Big Brawl")
    @brick = Character.create!(name: "Brick Manly", campaign_id: @campaign.id)
    @speedboat = Vehicle.create!(name: "Speedboat", campaign_id: @campaign.id)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
  end

  describe "POST /api/v1/fights/:fight_id/character_effects" do
    it "creates a character effect for a fight and character" do
      @fight.fight_characters.create!(character_id: @brick.id, shot: 10)
      post "/api/v1/fights/#{@fight.id}/character_effects", headers: @headers, params: {
        character_effect: {
          title: "Bonus",
          character_id: @brick.id
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("Bonus")
      expect(@brick.reload.character_effects.first.title).to eq("Bonus")
    end

    it "creates a character effect for a fight and a vehicle" do
      @fight.fight_characters.create!(vehicle_id: @speedboat.id, shot: 10)
      post "/api/v1/fights/#{@fight.id}/character_effects", headers: @headers, params: {
        character_effect: {
          title: "Bonus",
          vehicle_id: @speedboat.id
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("Bonus")
      expect(@speedboat.reload.character_effects.first.title).to eq("Bonus")
    end

    it "returns an error if there's no character_id" do
      post "/api/v1/fights/#{@fight.id}/character_effects", headers: @headers, params: {
        character_effect: {
          title: "Bonus",
        }
      }
      expect(response).to have_http_status(400)
      body = JSON.parse(response.body)
      expect(body["character"]).to eq(["must be present if vehicle is not set"])
      expect(body["vehicle"]).to eq(["must be present if character is not set"])
      expect(CharacterEffect.count).to eq(0)
    end

    it "returns an error if the character isn't in the fight" do
      @space = @campaign.fights.create!(name: "Space")
      post "/api/v1/fights/#{@fight.id}/character_effects", headers: @headers, params: {
        character_effect: {
          title: "Bonus",
          character_id: @brick.id
        }
      }
      expect(response).to have_http_status(400)
      body = JSON.parse(response.body)
      expect(body["character"]).to eq(["must belong to the fight"])
      expect(CharacterEffect.count).to eq(0)
    end

    it "returns an error if the vehicle isn't in the fight" do
      @space = @campaign.fights.create!(name: "Space")
      post "/api/v1/fights/#{@fight.id}/character_effects", headers: @headers, params: {
        character_effect: {
          title: "Bonus",
          vehicle_id: @speedboat.id
        }
      }
      expect(response).to have_http_status(400)
      body = JSON.parse(response.body)
      expect(body["vehicle"]).to eq(["must belong to the fight"])
      expect(CharacterEffect.count).to eq(0)
    end

    it "requires authentication" do
      @fight.fight_characters.create!(character_id: @brick.id, shot: 10)
      post "/api/v1/fights/#{@fight.id}/character_effects", params: {
        character_effect: {
          title: "Bonus",
          character_id: @brick.id
        }
      }
      expect(response).to have_http_status(:unauthorized)
      expect(CharacterEffect.count).to eq(0)
    end
  end

  describe "PATCH /api/v1/fights/:fight_id/character_effects/:id" do
    it "updates a character_effect" do
      @fight.characters << @brick
      @character_effect = CharacterEffect.create!(character_id: @brick.id, fight_id: @fight.id, title: "Bonuss")
      patch "/api/v1/fights/#{@fight.id}/character_effects/#{@character_effect.id}", headers: @headers, params: {
        character_effect: {
          title: "Bonus",
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("Bonus")
      expect(@brick.reload.character_effects.first.title).to eq("Bonus")
    end

    it "updates a character_effect on a vehicle" do
      @fight.vehicles << @speedboat
      @character_effect = CharacterEffect.create!(vehicle_id: @speedboat.id, fight_id: @fight.id, title: "Bonuss")
      patch "/api/v1/fights/#{@fight.id}/character_effects/#{@character_effect.id}", headers: @headers, params: {
        character_effect: {
          title: "Bonus",
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("Bonus")
      expect(@speedboat.reload.character_effects.first.title).to eq("Bonus")
    end

    it "returns error if you update a character_effect to remove character_id" do
      @fight.fight_characters.create!(character_id: @brick.id, shot: 10)
      @character_effect = CharacterEffect.create!(character_id: @brick.id, fight_id: @fight.id, title: "Bonuss")
      patch "/api/v1/fights/#{@fight.id}/character_effects/#{@character_effect.id}", headers: @headers, params: {
        character_effect: {
          character_id: nil
        }
      }
      expect(response).to have_http_status(400)
      body = JSON.parse(response.body)
      expect(body["character"]).to eq(["must be present if vehicle is not set"])
      expect(body["vehicle"]).to eq(["must be present if character is not set"])
    end

    it "returns error if you update a character_effect to remove vehicle_id" do
      @fight.fight_characters.create!(vehicle_id: @speedboat.id, shot: 10)
      @character_effect = CharacterEffect.create!(vehicle_id: @speedboat.id, fight_id: @fight.id, title: "Bonuss")
      patch "/api/v1/fights/#{@fight.id}/character_effects/#{@character_effect.id}", headers: @headers, params: {
        character_effect: {
          vehicle_id: nil
        }
      }
      expect(response).to have_http_status(400)
      body = JSON.parse(response.body)
      expect(body["character"]).to eq(["must be present if vehicle is not set"])
      expect(body["vehicle"]).to eq(["must be present if character is not set"])
    end

    it "requires authentication" do
      @fight.fight_characters.create!(character_id: @brick.id, shot: 10)
      @character_effect = CharacterEffect.create!(character_id: @brick.id, fight_id: @fight.id, title: "Bonuss")
      patch "/api/v1/fights/#{@fight.id}/character_effects/#{@character_effect.id}", params: {
        character_effect: {
          title: "Bonus",
        }
      }
      expect(response).to have_http_status(:unauthorized)
      expect(@character_effect.reload.title).to eq("Bonuss")
    end
  end

  describe "DELETE /api/v1/fights/:fight_id/character_effects/:id" do
    it "deletes the effect" do
      @fight.fight_characters.create!(character_id: @brick.id, shot: 10)
      @character_effect = CharacterEffect.create!(character_id: @brick.id, fight_id: @fight.id, title: "Bonuss")
      delete "/api/v1/fights/#{@fight.id}/character_effects/#{@character_effect.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(@brick.reload.character_effects).to be_empty
    end

    it "requires authentication" do
      @fight.fight_characters.create!(character_id: @brick.id, shot: 10)
      @character_effect = CharacterEffect.create!(character_id: @brick.id, fight_id: @fight.id, title: "Bonuss")
      delete "/api/v1/fights/#{@fight.id}/character_effects/#{@character_effect.id}"
      expect(response).to have_http_status(:unauthorized)
      expect(@character_effect.reload).to be_present
    end
  end

  def set_current_campaign(user, campaign)
    redis = Redis.new
    user_info = {
      "campaign_id" => campaign&.id
    }
    redis.set("user_#{user.id}", user_info.to_json)
  end
end
