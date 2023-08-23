require 'rails_helper'

RSpec.describe "Api::V1::Factions", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com", confirmed_at: Time.now, gamemaster: true)
    @campaign = @gamemaster.campaigns.create!(name: "Adventure")
    @fight = @campaign.fights.create!(name: "Big Brawl")
    @dragons = @campaign.factions.create!(name: "The Dragons")
    @ascended = @campaign.factions.create!(name: "The Ascended")
    @brick = Character.create!(name: "Brick Manly", action_values: { "Type" => "PC" }, faction_id: @dragons.id, campaign_id: @campaign.id)
    @boss = Character.create!(name: "Ugly Shing", action_values: { "Type" => "Boss" }, faction_id: @ascended.id, campaign_id: @campaign.id)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)

    set_current_campaign(@gamemaster, @campaign)
  end

  describe "GET /index" do
    it "returns http success" do
      get "/api/v1/factions", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body.map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end
  end

  describe "POST /create" do
    it "returns http success" do
      post "/api/v1/factions", params: { faction: { name: "The Fallen" } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Fallen")
    end
  end
end
