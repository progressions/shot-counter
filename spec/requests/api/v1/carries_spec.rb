require 'rails_helper'

RSpec.describe "Api::V1::Carries", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com", confirmed_at: Time.now)
    @campaign = @gamemaster.campaigns.create!(name: "Adventure")
    @fight = @campaign.fights.create!(name: "Big Brawl")
    @brick = Character.create!(name: "Brick Manly", action_values: { "Type" => "PC" }, campaign_id: @campaign.id)
    @boss = Character.create!(name: "Ugly Shing", action_values: { "Type" => "Boss" }, campaign_id: @campaign.id)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
  end

  describe "GET /api/v1/characters/:character_id/weapons" do
    it "gets all the weapons for a character" do
      @beretta = @campaign.weapons.create!(name: "Beretta M9", damage: 10, concealment: 2, reload_value: 3)
      @brick.weapons << @beretta
      get "/api/v1/characters/#{@brick.id}/weapons", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"]).to eq(JSON.parse([@beretta].to_json))
    end
  end

  describe "POST /api/v1/characters/:character_id/weapons" do
    it "adds a weapon to a character" do
      @beretta = @campaign.weapons.create!(name: "Beretta M9", damage: 10, concealment: 2, reload_value: 3)
      post "/api/v1/characters/#{@brick.id}/weapons", headers: @headers, params: {
        weapon: { id: @beretta.id }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"].map { |s| s["name"] }).to eq(["Beretta M9"])
      expect(@brick.reload.weapons).to include(@beretta)
    end
  end

  describe "DELETE /api/v1/characters/:character_id/weapons/:id" do
    it "removes a weapon from a character" do
      @beretta = @campaign.weapons.create!(name: "Beretta M9", damage: 10, concealment: 2, reload_value: 3)
      @brick.weapons << @beretta
      delete "/api/v1/characters/#{@brick.id}/weapons/#{@beretta.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(@brick.reload.weapons).to be_empty
    end
  end
end
