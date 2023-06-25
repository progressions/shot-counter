require 'rails_helper'

RSpec.describe "Api::V1::CharactersAndVehicles", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com", confirmed_at: Time.now, gamemaster: true)
    @campaign = @gamemaster.campaigns.create!(title: "Adventure")
    @fight = @campaign.fights.create!(name: "Big Brawl")
    @brick = Character.create!(name: "Brick Manly", action_values: { "Type" => "PC" }, campaign_id: @campaign.id)
    @boss = Character.create!(name: "Ugly Shing", action_values: { "Type" => "Boss" }, campaign_id: @campaign.id)
    @speedboat = Vehicle.create!(name: "Speedboat", campaign_id: @campaign.id)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
  end

  describe "GET /index" do
    it "gets all characters and vehicles and sorts them by name" do
      get "/api/v1/characters_and_vehicles", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Brick Manly", "Speedboat", "Ugly Shing"])
    end

    it "paginates the combined collection" do
      30.times { |i|
        Character.create!(name: "Enforcer #{i}", action_values: { "Type" => "Featured Foe" }, campaign_id: @campaign.id)
        Vehicle.create!(name: "Speedboat #{i}", campaign_id: @campaign.id)
      }
      get "/api/v1/characters_and_vehicles", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].length).to eq(50)
      expect(body["meta"]).to eq({"current_page"=>1, "next_page"=>2, "prev_page"=>nil, "total_count"=>63, "total_pages"=>2})
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
