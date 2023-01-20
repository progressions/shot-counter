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
      post "/api/v1/character_effects", headers: @headers, params: {
        character_effect: {
          title: "Bonus",
          fight_id: @fight.id,
          character_id: @brick.id
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("Bonus")
      expect(@brick.reload.character_effects.first.title).to eq("Bonus")
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
