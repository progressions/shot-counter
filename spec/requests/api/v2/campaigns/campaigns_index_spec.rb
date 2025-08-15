require "rails_helper"
RSpec.describe "Api::V2::Campaigns", type: :request do
  before(:each) do
    # users
    @admin = User.create!(email: "admin@example.com", confirmed_at: Time.now, admin: true, first_name: "Admin", last_name: "User", name: "Admin User")
    @gamemaster = User.create!(email: "gamemaster@example.com", confirmed_at: Time.now, gamemaster: true, first_name: "Game", last_name: "Master", name: "Game Master")
    @player = User.create!(email: "player@example.com", confirmed_at: Time.now, gamemaster: false, first_name: "Player", last_name: "One", name: "Player One")
    @inactive_user = User.create!(email: "inactive@example.com", confirmed_at: Time.now, active: false, first_name: "Inactive", last_name: "User", name: "Inactive User")
    # campaigns
    @campaign = @gamemaster.campaigns.create!(name: "Adventure", description: "Epic adventure", active: true, user_ids: [@player.id])
    @other_campaign = @gamemaster.campaigns.create!(name: "Quest", description: "Heroic quest", active: true)
    @inactive_campaign = @gamemaster.campaigns.create!(name: "Old Campaign", description: "Retired campaign", active: false)
    # factions
    @dragons = @campaign.factions.create!(name: "The Dragons", description: "A bunch of heroes.")
    @ascended = @campaign.factions.create!(name: "The Ascended", description: "A bunch of villains.")
    # junctures
    @modern = @campaign.junctures.create!(name: "Modern", faction_id: @dragons.id)
    @ancient = @campaign.junctures.create!(name: "Ancient", faction_id: @ascended.id)
    # fight
    @fight = @campaign.fights.create!(name: "Big Brawl")
    # characters
    @bandit = Character.create!(name: "Bandit", action_values: { "Type" => "PC", "Archetype" => "Bandit" }, campaign_id: @campaign.id, is_template: true, user_id: @gamemaster.id)
    @brick = Character.create!(
      name: "Brick Manly",
      action_values: { "Type" => "PC", "Archetype" => "Everyday Hero", "Martial Arts" => 13, "MainAttack" => "Martial Arts" },
      description: { "Appearance" => "He's Beretta 92FS, son" },
      campaign_id: @campaign.id,
      faction_id: @dragons.id,
      juncture_id: @modern.id,
      user_id: @player.id,
    )
    # vehicles
    @tank = @campaign.vehicles.create!(name: "Tank", campaign_id: @campaign.id, faction_id: @dragons.id, juncture_id: @modern.id)
    @jet = @campaign.vehicles.create!(name: "Jet", campaign_id: @campaign.id, faction_id: @ascended.id, juncture_id: @ancient.id)
    @admin_headers = Devise::JWT::TestHelpers.auth_headers({}, @admin)
    @gamemaster_headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    @player_headers = Devise::JWT::TestHelpers.auth_headers({}, @player)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end

  describe "GET /index" do
    context "when user is gamemaster" do
      it "gets all active campaigns owned by the gamemaster" do
        get "/api/v2/campaigns", headers: @gamemaster_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["campaigns"].map { |c| c["name"] }).to eq(["Quest", "Adventure"])
      end

      it "returns campaign attributes" do
        get "/api/v2/campaigns", params: { search: "Adventure" }, headers: @gamemaster_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["campaigns"].length).to eq(1)
        expect(body["campaigns"][0]).to include("name" => "Adventure", "description" => "Epic adventure", "user_ids" => [@player.id])
        expect(body["campaigns"][0].keys).to contain_exactly("id", "name", "description", "created_at", "updated_at", "active", "user_ids", "entity_class", "image_positions", "characters", "image_url", "gamemaster", "gamemaster_id")
      end

      it "sorts by created_at ascending" do
        get "/api/v2/campaigns", params: { sort: "created_at", order: "asc" }, headers: @gamemaster_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["campaigns"].map { |c| c["name"] }).to eq(["Adventure", "Quest"])
      end

      it "sorts by created_at descending" do
        get "/api/v2/campaigns", params: { sort: "created_at", order: "desc" }, headers: @gamemaster_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["campaigns"].map { |c| c["name"] }).to eq(["Quest", "Adventure"])
      end

      it "sorts by name ascending" do
        get "/api/v2/campaigns", params: { sort: "name", order: "asc" }, headers: @gamemaster_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["campaigns"].map { |c| c["name"] }).to eq(["Adventure", "Quest"])
      end

      it "sorts by name descending" do
        get "/api/v2/campaigns", params: { sort: "name", order: "desc" }, headers: @gamemaster_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["campaigns"].map { |c| c["name"] }).to eq(["Quest", "Adventure"])
      end

      it "filters by id" do
        get "/api/v2/campaigns", params: { id: @campaign.id }, headers: @gamemaster_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["campaigns"].map { |c| c["name"] }).to eq(["Adventure"])
      end

      it "filters by search string" do
        get "/api/v2/campaigns", params: { search: "Quest" }, headers: @gamemaster_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["campaigns"].map { |c| c["name"] }).to eq(["Quest"])
      end

      it "filters by character_id" do
        get "/api/v2/campaigns", params: { character_id: @brick.id }, headers: @gamemaster_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["campaigns"].map { |c| c["name"] }).to eq(["Adventure"])
      end

      it "filters by vehicle_id" do
        get "/api/v2/campaigns", params: { vehicle_id: @tank.id }, headers: @gamemaster_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["campaigns"].map { |c| c["name"] }).to eq(["Adventure"])
      end

      it "gets only active campaigns when show_all is false" do
        get "/api/v2/campaigns", params: { show_all: "false" }, headers: @gamemaster_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["campaigns"].map { |c| c["name"] }).to eq(["Quest", "Adventure"])
        expect(body["campaigns"].map { |c| c["name"] }).not_to include("Old Campaign")
      end

      it "gets all campaigns when show_all is true" do
        get "/api/v2/campaigns", params: { show_all: "true" }, headers: @gamemaster_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["campaigns"].map { |c| c["name"] }).to eq(["Old Campaign", "Quest", "Adventure"])
      end
    end

    context "when user is admin" do
      it "gets all active campaigns owned by the admin" do
        admin_campaign = @admin.campaigns.create!(name: "Admin Campaign", description: "Admin adventure", active: true)
        get "/api/v2/campaigns", headers: @admin_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["campaigns"].map { |c| c["name"] }).to eq(["Admin Campaign"])
      end
    end

    context "when user is a player" do
      it "gets all active campaigns they are a player in" do
        get "/api/v2/campaigns", headers: @player_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["campaigns"].map { |c| c["name"] }).to eq(["Adventure"])
      end
    end
  end
end
