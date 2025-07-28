require "rails_helper"
require "securerandom"

RSpec.describe "Api::V1::Characters", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com", confirmed_at: Time.now, gamemaster: true)
    @campaign = @gamemaster.campaigns.create!(name: "Adventure")
    @fight = @campaign.fights.create!(name: "Big Brawl")
    @brick = Character.create!(name: "Brick Manly", action_values: { "Type" => "PC" }, campaign_id: @campaign.id)
    @boss = Character.create!(name: "Ugly Shing", action_values: { "Type" => "Boss" }, campaign_id: @campaign.id)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    @dragons = @campaign.factions.create!(name: "The Dragons")
    set_current_campaign(@gamemaster, @campaign)
  end

  describe "GET /index" do
    it "gets all characters" do
      get "/api/v1/characters", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Ugly Shing", "Brick Manly"])
    end
  end

  describe "POST /create" do
    it "creates a character" do
      post "/api/v1/characters", params: { character: { name: "Serena Tessaro", faction_id: @dragons.id, action_values: { "Type" => "PC" } } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Serena Tessaro")
      expect(body["faction"]["name"]).to eq("The Dragons")
      character = Character.find(body["id"])
      expect(character.faction.name).to eq("The Dragons")
    end

    it "creates a task" do
      post "/api/v1/characters", params: { character: { name: "Defuse the Bomb", task: true, action_values: { "Type" => "PC" } } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Defuse the Bomb")
      expect(body["task"]).to eq(true)
      character = Character.find(body["id"])
      expect(character.task).to eq(true)
    end
  end

  describe "GET /show" do
    it "shows a character" do
      get "/api/v1/characters/#{@brick[:id]}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly")
    end
  end

  describe "PUT /update" do
    it "updates a character" do
      put "/api/v1/characters/#{@brick[:id]}", params: { character: { name: "Brick Manly, Esq" } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly, Esq")
    end

    it "updates a character's faction" do
      put "/api/v1/characters/#{@brick[:id]}", params: { character: { faction_id: @dragons.id } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["faction"]["name"]).to eq("The Dragons")
      character = Character.find(body["id"])
      expect(character.faction.name).to eq("The Dragons")
    end

    it "removes a character's faction" do
      put "/api/v1/characters/#{@boss[:id]}", params: { character: { faction_id: nil } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["faction_id"]).to eq(nil)
      expect(body["faction"]).to eq(nil)
      character = Character.find(body["id"])
      expect(character.faction).to eq(nil)
    end

    it "updates a character's notion_page_id" do
      uuid = SecureRandom.uuid
      put "/api/v1/characters/#{@brick[:id]}", params: { character: { notion_page_id: uuid } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["notion_page_id"]).to eq(uuid)
      character = Character.find(body["id"])
      expect(character.notion_page_id).to eq(uuid)
    end
  end

  describe "DELETE /destroy" do
    it "destroys a character" do
      delete "/api/v1/characters/#{@brick[:id]}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(Character.count).to eq(1)
    end
  end
end
