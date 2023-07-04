require 'rails_helper'

RSpec.describe "Api::V1::CharactersAndVehicles", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com", confirmed_at: Time.now, gamemaster: true)
    @campaign = @gamemaster.campaigns.create!(name: "Adventure")
    @fight = @campaign.fights.create!(name: "Big Brawl")
    @good_guys = @campaign.factions.create!(name: "The Good Guys")
    @bad_guys = @campaign.factions.create!(name: "The Bad Guys")
    @brick = Character.create!(name: "Brick Manly", action_values: { "Type" => "PC", "Archetype" => "Everyday Hero", "Faction" => "The Good Guys" }, campaign_id: @campaign.id)
    @boss = Character.create!(name: "Ugly Shing", action_values: { "Type" => "Boss", "Archetype" => "Killer", "Faction" => "The Bad Guys" }, campaign_id: @campaign.id)
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

    it "gets factions for characters" do
      get "/api/v1/characters_and_vehicles", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Bad Guys", "The Good Guys"])
    end

    it "gets archetypes for characters" do
      get "/api/v1/characters_and_vehicles", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["archetypes"]).to eq(["Everyday Hero", "Killer"])
    end

    it "shows characters who aren't in a given fight by fight_id" do
      @fight.characters << @boss
      get "/api/v1/characters_and_vehicles?fight_id=#{@fight[:id]}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Brick Manly", "Speedboat"])
    end

    it "shows all characters if fight_id isn't given" do
      get "/api/v1/characters_and_vehicles", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Brick Manly", "Speedboat", "Ugly Shing"])
    end

    it "shows inactive characters if show_all is true" do
      @brick.update!(active: false)
      get "/api/v1/characters_and_vehicles?show_all=true", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Brick Manly", "Speedboat", "Ugly Shing"])
    end

    it "filters characters by faction name" do
      get "/api/v1/characters_and_vehicles?faction=The%20Good%20Guys", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Brick Manly"])
    end

    it "filters characters by archetype" do
      get "/api/v1/characters_and_vehicles?archetype=Everyday%20Hero", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Brick Manly"])
    end

    it "filters characters by character_type" do
      get "/api/v1/characters_and_vehicles?character_type=PC", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Brick Manly", "Speedboat"])
    end

    it "filters characters by search string matching name" do
      get "/api/v1/characters_and_vehicles?search=Brick", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["characters"].map { |c| c["name"] }).to eq(["Brick Manly"])
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
end
