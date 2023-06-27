require "rails_helper"

RSpec.describe "Fights", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com", confirmed_at: Time.now)
    @campaign = @gamemaster.campaigns.create!(title: "Adventure")
    @fight = @campaign.fights.create!(name: "Big Brawl")
    @brick = Character.create!(name: "Brick Manly", action_values: { "Type" => "PC" }, campaign_id: @campaign.id)
    @boss = Character.create!(name: "Ugly Shing", action_values: { "Type" => "Boss" }, campaign_id: @campaign.id)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
  end

  describe "GET /api/v1/fights/:id" do
    it "returns a fight" do
      @fight.fight_characters.create!(character_id: @brick.id, shot: 10)
      @fight.fight_characters.create!(character_id: @boss.id, shot: 8)
      get "/api/v1/fights/#{@fight.id}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Big Brawl")
      expect(body["active"]).to be_truthy
      expect(body["characters"].map { |c| c["name"] }).to eq(["Brick Manly", "Ugly Shing"])
      expect(body["shot_order"].map { |shot, _characters| shot }).to eq([10, 8])

      # Shot includes shot number and characters
      expect(body["shot_order"][0][0]).to eq(10)
      expect(body["shot_order"][0][1].map { |c| c["name"] }).to eq(["Brick Manly"])

      # Shot includes shot number and characters
      expect(body["shot_order"][1][0]).to eq(8)
      expect(body["shot_order"][1][1].map { |c| c["name"] }).to eq(["Ugly Shing"])
    end

    it "returns the character effects for each character" do
      fight_character = @fight.fight_characters.create!(character_id: @brick.id, shot: 10)

      @character_effect = fight_character.character_effects.create!(title: "Bonus")

      get "/api/v1/fights/#{@fight.id}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)

      expect(body["character_effects"][@brick.id][0]["title"]).to eq("Bonus")
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
