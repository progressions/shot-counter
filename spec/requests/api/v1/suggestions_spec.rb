require 'rails_helper'

RSpec.describe "Api::V1::Suggestions", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com", confirmed_at: Time.now)
    @campaign = @gamemaster.campaigns.create!(name: "Adventure")
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
  end

  describe "GET /api/v1/suggestions" do
    it "returns suggestions for a valid query" do
      # Create test data
      @character = @campaign.characters.create!(name: "Brick Manly", action_values: { "Type" => "PC" }, active: true)
      @vehicle = @campaign.vehicles.create!(name: "Brutus Truck", action_values: { "Type" => "PC" }, active: true)
      @site = @campaign.sites.create!(name: "Brutus Base", secret: false)
      @other_character = @campaign.characters.create!(name: "Sam Stealth", action_values: { "Type" => "NPC" }, active: true)

      # Verify data is queryable
      character_count = Character.where(campaign_id: @campaign.id, name: "Brick Manly", active: true).count
      vehicle_count = Vehicle.where(campaign_id: @campaign.id, name: "Brutus Truck", active: true).count
      site_count = Site.where(campaign_id: @campaign.id, name: "Brutus Base", secret: false).count
      Rails.logger.debug "Character count: #{character_count}, Vehicle count: #{vehicle_count}, Site count: #{site_count}"
      expect(character_count).to eq(1)
      expect(vehicle_count).to eq(1)
      expect(site_count).to eq(1)

      get "/api/v1/suggestions", headers: @headers, params: { query: "br" }

      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expected = [
        {
          "className" => "Character",
          "id" => @character.id,
          "label" => "Brick Manly"
        },
        {
          "className" => "Vehicle",
          "id" => @vehicle.id,
          "label" => "Brutus Truck"
        },
        {
          "className" => "Site",
          "id" => @site.id,
          "label" => "Brutus Base"
        }
      ]
      expect(body).to match_array(expected)
    end

    it "excludes inactive characters and vehicles, and secret sites" do
      # Create inactive/secret test data
      @inactive_character = @campaign.characters.create!(name: "Brick Inactive", action_values: { "Type" => "PC" }, active: false)
      @inactive_vehicle = @campaign.vehicles.create!(name: "Brutus Broken", action_values: { "Type" => "PC" }, active: false)
      @secret_site = @campaign.sites.create!(name: "Brutus Secret", secret: true)
      # Create active/visible test data
      @character = @campaign.characters.create!(name: "Brick Manly", action_values: { "Type" => "PC" }, active: true)
      @vehicle = @campaign.vehicles.create!(name: "Brutus Truck", action_values: { "Type" => "PC" }, active: true)
      @site = @campaign.sites.create!(name: "Brutus Base", secret: false)

      # Verify data is queryable
      character_count = Character.where(campaign_id: @campaign.id, name: "Brick Manly", active: true).count
      vehicle_count = Vehicle.where(campaign_id: @campaign.id, name: "Brutus Truck", active: true).count
      site_count = Site.where(campaign_id: @campaign.id, name: "Brutus Base", secret: false).count
      Rails.logger.debug "Character count: #{character_count}, Vehicle count: #{vehicle_count}, Site count: #{site_count}"
      expect(character_count).to eq(1)
      expect(vehicle_count).to eq(1)
      expect(site_count).to eq(1)

      get "/api/v1/suggestions", headers: @headers, params: { query: "br" }

      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expected = [
        {
          "className" => "Character",
          "id" => @character.id,
          "label" => "Brick Manly"
        },
        {
          "className" => "Vehicle",
          "id" => @vehicle.id,
          "label" => "Brutus Truck"
        },
        {
          "className" => "Site",
          "id" => @site.id,
          "label" => "Brutus Base"
        }
      ]
      expect(body).to match_array(expected)
    end

    it "returns an empty array for an empty query" do
      @character = @campaign.characters.create!(name: "Brick Manly", action_values: { "Type" => "PC" }, active: true)
      @vehicle = @campaign.vehicles.create!(name: "Brutus Truck", action_values: { "Type" => "PC" }, active: true)
      @site = @campaign.sites.create!(name: "Brutus Base", secret: false)

      get "/api/v1/suggestions", headers: @headers, params: { query: "" }

      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body).to eq([])
    end

    it "returns an empty array for a whitespace-only query" do
      @character = @campaign.characters.create!(name: "Brick Manly", action_values: { "Type" => "PC" }, active: true)
      @vehicle = @campaign.vehicles.create!(name: "Brutus Truck", action_values: { "Type" => "PC" }, active: true)
      @site = @campaign.sites.create!(name: "Brutus Base", secret: false)

      get "/api/v1/suggestions", headers: @headers, params: { query: "   " }

      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body).to eq([])
    end

    it "returns no matches for a non-matching query" do
      @character = @campaign.characters.create!(name: "Brick Manly", action_values: { "Type" => "PC" }, active: true)
      @vehicle = @campaign.vehicles.create!(name: "Brutus Truck", action_values: { "Type" => "PC" }, active: true)
      @site = @campaign.sites.create!(name: "Brutus Base", secret: false)

      get "/api/v1/suggestions", headers: @headers, params: { query: "xyz" }

      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body).to eq([])
    end

    it "returns unauthorized without valid authentication" do
      @character = @campaign.characters.create!(name: "Brick Manly", action_values: { "Type" => "PC" }, active: true)

      get "/api/v1/suggestions", params: { query: "brick" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "only returns suggestions from the current campaign" do
      # Create data in a different campaign
      other_campaign = @gamemaster.campaigns.create!(name: "Other Adventure")
      other_campaign.characters.create!(name: "Brutus Other", action_values: { "Type" => "NPC" }, active: true)
      other_campaign.vehicles.create!(name: "Brutus Other Truck", action_values: { "Type" => "PC" }, active: true)
      other_campaign.sites.create!(name: "Brutus Other Base", secret: false)

      # Create data in the current campaign
      @character = @campaign.characters.create!(name: "Brick Manly", action_values: { "Type" => "PC" }, active: true)
      @vehicle = @campaign.vehicles.create!(name: "Brutus Truck", action_values: { "Type" => "PC" }, active: true)
      @site = @campaign.sites.create!(name: "Brutus Base", secret: false)

      # Verify data is queryable
      character_count = Character.where(campaign_id: @campaign.id, name: "Brick Manly", active: true).count
      vehicle_count = Vehicle.where(campaign_id: @campaign.id, name: "Brutus Truck", active: true).count
      site_count = Site.where(campaign_id: @campaign.id, name: "Brutus Base", secret: false).count
      Rails.logger.debug "Character count: #{character_count}, Vehicle count: #{vehicle_count}, Site count: #{site_count}"
      expect(character_count).to eq(1)
      expect(vehicle_count).to eq(1)
      expect(site_count).to eq(1)

      get "/api/v1/suggestions", headers: @headers, params: { query: "br" }

      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expected = [
        {
          "className" => "Character",
          "id" => @character.id,
          "label" => "Brick Manly"
        },
        {
          "className" => "Vehicle",
          "id" => @vehicle.id,
          "label" => "Brutus Truck"
        },
        {
          "className" => "Site",
          "id" => @site.id,
          "label" => "Brutus Base"
        }
      ]
      expect(body).to match_array(expected)
    end
  end
end
