require 'rails_helper'

RSpec.describe "API V2 Cache Buster", type: :request do
  before(:each) do
    allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
    
    # Create users using the same pattern as fights spec
    @gamemaster = User.create!(
      email: "gamemaster@example.com",
      confirmed_at: Time.now,
      gamemaster: true,
      first_name: "Game",
      last_name: "Master"
    )
    
    @campaign = @gamemaster.campaigns.create!(
      name: "Test Campaign",
      active: true
    )
    
    # Set up auth headers using Devise JWT helpers
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end

  describe "Characters endpoint" do
    before do
      @character = Character.create!(
        name: "Test Character",
        campaign: @campaign,
        user: @gamemaster,
        action_values: { "Type" => "PC" }
      )
    end

    it "returns characters without cache_buster" do
      get "/api/v2/characters", headers: @headers
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data["characters"]).to be_an(Array)
    end

    it "returns characters with cache_buster=true" do
      get "/api/v2/characters?cache_buster=true", headers: @headers
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data["characters"]).to be_an(Array)
    end

    it "includes newly created characters with cache_buster" do
      # First request to populate cache
      get "/api/v2/characters", headers: @headers
      initial_data = JSON.parse(response.body)
      initial_count = initial_data["characters"].size

      # Create new character
      Character.create!(
        name: "New Character #{Time.now.to_i}",
        campaign: @campaign,
        user: @gamemaster,
        action_values: { "Type" => "NPC" }
      )

      # Request with cache_buster should show new character
      get "/api/v2/characters?cache_buster=true", headers: @headers
      fresh_data = JSON.parse(response.body)
      expect(fresh_data["characters"].size).to eq(initial_count + 1)
    end
  end

  describe "Campaigns endpoint" do
    it "returns campaigns without cache_buster" do
      get "/api/v2/campaigns", headers: @headers
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data["campaigns"]).to be_an(Array)
    end

    it "returns campaigns with cache_buster=true" do
      get "/api/v2/campaigns?cache_buster=true", headers: @headers
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data["campaigns"]).to be_an(Array)
    end
  end

  describe "Schticks endpoint" do
    before do
      @schtick = Schtick.create!(
        name: "Test Schtick",
        campaign: @campaign,
        category: "Sorcery",
        path: "Fire"
      )
    end

    it "returns schticks without cache_buster" do
      get "/api/v2/schticks", headers: @headers
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data["schticks"]).to be_an(Array)
    end

    it "returns schticks with cache_buster=true" do
      get "/api/v2/schticks?cache_buster=true", headers: @headers
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data["schticks"]).to be_an(Array)
    end
  end

  describe "Weapons endpoint" do
    before do
      @weapon = Weapon.create!(
        name: "Test Weapon",
        campaign: @campaign,
        damage: 10,
        concealment: 1,
        reload_value: 1
      )
    end

    it "returns weapons without cache_buster" do
      get "/api/v2/weapons", headers: @headers
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data["weapons"]).to be_an(Array)
    end

    it "returns weapons with cache_buster=true" do
      get "/api/v2/weapons?cache_buster=true", headers: @headers
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data["weapons"]).to be_an(Array)
    end
  end

  describe "Vehicles endpoint" do
    before do
      @vehicle = Vehicle.create!(
        name: "Test Vehicle",
        campaign: @campaign,
        user: @gamemaster,
        action_values: {}
      )
    end

    it "returns vehicles without cache_buster" do
      get "/api/v2/vehicles", headers: @headers
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data["vehicles"]).to be_an(Array)
    end

    it "returns vehicles with cache_buster=true" do
      get "/api/v2/vehicles?cache_buster=true", headers: @headers
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data["vehicles"]).to be_an(Array)
    end
  end

  describe "Sites endpoint" do
    before do
      @site = Site.create!(
        name: "Test Site",
        campaign: @campaign
      )
    end

    it "returns sites without cache_buster" do
      get "/api/v2/sites", headers: @headers
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data["sites"]).to be_an(Array)
    end

    it "returns sites with cache_buster=true" do
      get "/api/v2/sites?cache_buster=true", headers: @headers
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data["sites"]).to be_an(Array)
    end
  end

  describe "Parties endpoint" do
    before do
      @party = Party.create!(
        name: "Test Party",
        campaign: @campaign
      )
    end

    it "returns parties without cache_buster" do
      get "/api/v2/parties", headers: @headers
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data["parties"]).to be_an(Array)
    end

    it "returns parties with cache_buster=true" do
      get "/api/v2/parties?cache_buster=true", headers: @headers
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data["parties"]).to be_an(Array)
    end
  end

  describe "Factions endpoint" do
    before do
      @faction = Faction.create!(
        name: "Test Faction",
        campaign: @campaign
      )
    end

    it "returns factions without cache_buster" do
      get "/api/v2/factions", headers: @headers
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data["factions"]).to be_an(Array)
    end

    it "returns factions with cache_buster=true" do
      get "/api/v2/factions?cache_buster=true", headers: @headers
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data["factions"]).to be_an(Array)
    end
  end

  describe "Fights endpoint" do
    before do
      @fight = Fight.create!(
        name: "Test Fight",
        campaign: @campaign,
        sequence: 0
      )
    end

    it "returns fights without cache_buster" do
      get "/api/v2/fights", headers: @headers
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data["fights"]).to be_an(Array)
    end

    it "returns fights with cache_buster=true" do
      get "/api/v2/fights?cache_buster=true", headers: @headers
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data["fights"]).to be_an(Array)
    end
  end

  describe "Authorization" do
    before(:each) do
      @other_user = User.create!(
        email: "other@example.com",
        confirmed_at: Time.now,
        first_name: "Other",
        last_name: "User",
        gamemaster: true
      )
      
      @other_campaign = @other_user.campaigns.create!(
        name: "Other Campaign",
        active: true
      )
    end
    
    it "respects authorization even with cache_buster" do
      # User shouldn't see campaigns they're not part of
      other_headers = Devise::JWT::TestHelpers.auth_headers({}, @other_user)
      set_current_campaign(@other_user, @other_campaign)
      
      get "/api/v2/campaigns?cache_buster=true", headers: other_headers
      expect(response).to have_http_status(:success)
      
      data = JSON.parse(response.body)
      campaign_ids = data["campaigns"].map { |c| c["id"] }
      expect(campaign_ids).not_to include(@campaign.id)
      expect(campaign_ids).to include(@other_campaign.id)
    end
  end
end