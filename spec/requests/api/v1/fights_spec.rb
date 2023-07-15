require "rails_helper"

RSpec.describe "Fights", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com", confirmed_at: Time.now)
    @campaign = @gamemaster.campaigns.create!(name: "Adventure")
    @fight = @campaign.fights.create!(name: "Big Brawl")
    @brick = Character.create!(name: "Brick Manly", action_values: { "Type" => "PC" }, campaign_id: @campaign.id)
    @truck = Vehicle.create!(name: "Truck", action_values: { "Acceleration" => "7" }, campaign_id: @campaign.id)
    @boss = Character.create!(name: "Ugly Shing", action_values: { "Type" => "Boss" }, campaign_id: @campaign.id)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
  end

  describe "POST /api/v1/fights" do
    it "creates a fight" do
      post "/api/v1/fights", params: { fight: {
        name: "Museum Fight",
        description: "A fight in a museum",
      } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Museum Fight")
      expect(body["description"]).to eq("A fight in a museum")
      expect(body["active"]).to be_truthy
    end
  end

  describe "PATCH /api/v1/fights/:id" do
    it "updates a fight" do
      patch "/api/v1/fights/#{@fight.id}", params: { fight: {
        name: "Huge Brawl",
        description: "A very big brawl",
      } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Huge Brawl")
      expect(body["description"]).to eq("A very big brawl")
      expect(body["active"]).to be_truthy
    end
  end

  describe "DELETE /api/v1/fights/:id" do
    it "deletes a fight" do
      expect {
        delete "/api/v1/fights/#{@fight.id}", headers: @headers
      }.to change { Fight.count }.by(-1)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /api/v1/fights/:id" do
    it "returns a fight" do
      @fight.shots.create!(character_id: @brick.id, shot: 10)
      @fight.shots.create!(character_id: @boss.id, shot: 8)
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
      shot = @fight.shots.create!(character_id: @brick.id, shot: 10)
      truck_shot = @fight.shots.create!(vehicle_id: @truck.id, shot: 8)

      @character_effect = shot.character_effects.create!(name: "Bonus")
      @vehicle_effect = truck_shot.character_effects.create!(name: "Blizzard")

      get "/api/v1/fights/#{@fight.id}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)

      expect(body["character_effects"][shot.id].map { |e| e["name"] }).to eq(["Bonus"])
      expect(body["vehicle_effects"][truck_shot.id].map { |e| e["name"] }).to eq(["Blizzard"])
    end
  end
end
