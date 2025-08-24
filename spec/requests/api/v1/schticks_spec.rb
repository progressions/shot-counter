require 'rails_helper'

RSpec.describe "Schticks", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com", first_name: "Game", last_name: "Master", confirmed_at: Time.now)
    @campaign = @gamemaster.campaigns.create!(name: "Adventure")
    @fight = @campaign.fights.create!(name: "Big Brawl")
    @brick = Character.create!(name: "Brick Manly", action_values: { "Type" => "PC" }, campaign_id: @campaign.id)
    @boss = Character.create!(name: "Ugly Shing", action_values: { "Type" => "Boss" }, campaign_id: @campaign.id)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
  end

  describe "GET /api/v1/schticks" do
    it "gets all the schticks" do
      @blam = @campaign.schticks.create!(name: "Blam Blam Epigram", description: "Say a pithy phrase before firing a shot.", category: "Guns")
      get "/api/v1/schticks", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"]).to eq(JSON.parse([@blam].to_json))
    end

    it "gets schticks for a Foe, excluding schticks they already know" do
      @blam = @campaign.schticks.create!(name: "Blam Blam Epigram", description: "Say a pithy phrase before firing a shot.", category: "Guns")
      @big = @campaign.schticks.create!(name: "Very Big", description: "+3 to Strength checks.", category: "Martial Arts")
      @boss.schticks << @blam
      get "/api/v1/schticks?character_id=#{@boss.id}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"]).not_to include(JSON.parse(@blam.to_json))
      expect(body["schticks"]).to include(JSON.parse(@big.to_json))
    end
  end

  describe "GET /api/v1/schtick/:id" do
    it "gets a schtick" do
      @blam = @campaign.schticks.create!(name: "Blam Blam Epigram", description: "Say a pithy phrase before firing a shot.", category: "Guns")
      get "/api/v1/schticks/#{@blam.id}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq(@blam.name)
      expect(body["description"]).to eq(@blam.description)
      expect(body["category"]).to eq(@blam.category)
    end
  end

  describe "POST /api/v1/schticks" do
    it "creates a schtick" do
      post "/api/v1/schticks", headers: @headers, params: {
        schtick: {
          name: "Blam Blam Epigram",
          description: "Say a pithy phrase before firing a shot.",
          category: "Guns"
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Blam Blam Epigram")
    end
  end

  describe "PATCH /api/v1/schticks" do
    it "updates a schtick" do
      @blam = @campaign.schticks.create!(name: "Blam Blam Epigram", description: "Say a pithy phrase before firing a shot.", category: "Guns")
      patch "/api/v1/schticks/#{@blam.id}", headers: @headers, params: {
        schtick: {
          name: "Blam Blam",
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Blam Blam")
    end
  end

  describe "DELETE /api/v1/schticks/:id" do
    it "deletes a schtick" do
      @blam = @campaign.schticks.create!(name: "Blam Blam Epigram", description: "Say a pithy phrase before firing a shot.", category: "Guns")
      delete "/api/v1/schticks/#{@blam.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(Schtick.find_by(id: @blam.id)).not_to be_present
    end
  end
end
