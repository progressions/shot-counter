require 'rails_helper'

RSpec.describe "CharacterEffects", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com")
    @campaign = @gamemaster.campaigns.create!(title: "Adventure")
    @fight = @campaign.fights.create!(name: "Big Brawl")
    @brick = Character.create!(name: "Brick Manly", campaign_id: @campaign.id)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
  end

  describe "POST /api/v1/character_effects" do
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

    it "returns an error if there's no character_id" do
      post "/api/v1/fights/#{@fight.id}/character_effects", headers: @headers, params: {
        character_effect: {
          title: "Bonus",
        }
      }
      expect(response).to have_http_status(400)
      body = JSON.parse(response.body)
      expect(body["character"]).to eq(["must exist"])
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
  end

  describe "PATCH /api/v1/character_effects/:id" do
    it "updates a character_effect" do
      @fight.fight_characters.create!(character_id: @brick.id, shot: 10)
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
  end

  describe "DELETE /api/v1/character_effects/:id"

  def set_current_campaign(user, campaign)
    redis = Redis.new
    user_info = {
      "campaign_id" => campaign&.id
    }
    redis.set("user_#{user.id}", user_info.to_json)
  end
end
