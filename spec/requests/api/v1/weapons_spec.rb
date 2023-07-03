require 'rails_helper'

RSpec.describe "Api::V1::Weapons", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com", confirmed_at: Time.now)
    @campaign = @gamemaster.campaigns.create!(name: "Adventure")
    @fight = @campaign.fights.create!(name: "Big Brawl")
    @brick = Character.create!(name: "Brick Manly", action_values: { "Type" => "PC" }, campaign_id: @campaign.id)
    @boss = Character.create!(name: "Ugly Shing", action_values: { "Type" => "Boss" }, campaign_id: @campaign.id)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
  end

  describe "GET /api/v1/weapons" do
    it "gets all the weapons" do
      @beretta = @campaign.weapons.create!(name: "Beretta M9", damage: 10, concealment: 2, reload_value: 3)
      get "/api/v1/weapons", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["weapons"]).to eq(JSON.parse([@beretta].to_json))
    end
  end

  describe "GET /api/v1/weapon/:id" do
    it "gets a weapon" do
      @beretta = @campaign.weapons.create!(name: "Beretta M9", damage: 10, concealment: 2, reload_value: 3)
      get "/api/v1/weapons/#{@beretta.id}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body).to eq(JSON.parse(@beretta.to_json))
    end
  end

  describe "POST /api/v1/weapons" do
    it "creates a weapon" do
      post "/api/v1/weapons", headers: @headers, params: {
        weapon: {
          name: "Beretta M9",
          description: "As seen in A Better Tomorrow",
          damage: 10,
          concealment: 2,
          reload_value: 3,
          juncture: "Modern",
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Beretta M9")
      expect(body["damage"]).to eq(10)
      expect(body["concealment"]).to eq(2)
      expect(body["reload_value"]).to eq(3)
      expect(body["description"]).to eq("As seen in A Better Tomorrow")
      expect(body["juncture"]).to eq("Modern")
    end
  end

  describe "PATCH /api/v1/weapons" do
    it "updates a weapon" do
      @beretta = @campaign.weapons.create!(name: "Beretta M9", damage: 10, concealment: 2, reload_value: 3)
      patch "/api/v1/weapons/#{@beretta.id}", headers: @headers, params: {
        weapon: {
          name: "Beretta",
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Beretta")
    end
  end

  describe "DELETE /api/v1/weapons/:id" do
    it "deletes a weapon" do
      @beretta = @campaign.weapons.create!(name: "Beretta M9", damage: 10, concealment: 2, reload_value: 3)
      delete "/api/v1/weapons/#{@beretta.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(Weapon.find_by(id: @beretta.id)).not_to be_present
    end
  end
end
