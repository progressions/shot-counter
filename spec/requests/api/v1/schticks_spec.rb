require 'rails_helper'

RSpec.describe "Schticks", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com", confirmed_at: Time.now)
    @campaign = @gamemaster.campaigns.create!(title: "Adventure")
    @fight = @campaign.fights.create!(name: "Big Brawl")
    @brick = Character.create!(name: "Brick Manly", action_values: { "Type" => "PC" }, campaign_id: @campaign.id)
    @boss = Character.create!(name: "Ugly Shing", action_values: { "Type" => "Boss" }, campaign_id: @campaign.id)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
  end

  describe "GET /api/v1/schticks" do
    it "gets all the schticks" do
      @blam = @campaign.schticks.create!(title: "Blam Blam Epigram", description: "Say a pithy phrase before firing a shot.")
      get "/api/v1/schticks", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"]).to eq(JSON.parse([@blam].to_json))
    end

    it "gets schticks for a Foe, excluding schticks they already know" do
      @blam = @campaign.schticks.create!(title: "Blam Blam Epigram", description: "Say a pithy phrase before firing a shot.")
      @big = @campaign.schticks.create!(title: "Very Big", description: "+3 to Strength checks.")
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
      @blam = @campaign.schticks.create!(title: "Blam Blam Epigram", description: "Say a pithy phrase before firing a shot.")
      get "/api/v1/schticks/#{@blam.id}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body).to eq(JSON.parse(@blam.to_json))
    end
  end

  describe "POST /api/v1/schticks" do
    it "creates a schtick" do
      post "/api/v1/schticks", headers: @headers, params: {
        schtick: {
          title: "Blam Blam Epigram",
          description: "Say a pithy phrase before firing a shot."
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("Blam Blam Epigram")
    end
  end

  describe "PATCH /api/v1/schticks" do
    it "updates a schtick" do
      @blam = @campaign.schticks.create!(title: "Blam Blam Epigram", description: "Say a pithy phrase before firing a shot.")
      patch "/api/v1/schticks/#{@blam.id}", headers: @headers, params: {
        schtick: {
          title: "Blam Blam",
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("Blam Blam")
    end
  end

  describe "DELETE /api/v1/schticks/:id" do
    it "deletes a schtick" do
      @blam = @campaign.schticks.create!(title: "Blam Blam Epigram", description: "Say a pithy phrase before firing a shot.")
      delete "/api/v1/schticks/#{@blam.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(Schtick.find_by(id: @blam.id)).not_to be_present
    end
  end
end
