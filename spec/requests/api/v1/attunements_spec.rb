require 'rails_helper'

RSpec.describe "Api::V1::CharacterSites", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com", first_name: "Game", last_name: "Master", confirmed_at: Time.now)
    @campaign = @gamemaster.campaigns.create!(name: "Adventure")
    @brick = Character.create!(name: "Brick Manly", action_values: { "Type" => "PC" }, campaign_id: @campaign.id)
    @boss = Character.create!(name: "Ugly Shing", action_values: { "Type" => "Boss" }, campaign_id: @campaign.id)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
  end

  describe "GET /api/v1/characters/:character_id/sites" do
    it "gets all of a character's sites" do
      @other_site = @campaign.sites.create!(name: "Baseball Field")
      @site = @brick.sites.create!(name: "Manly Steel Mill", campaign_id: @campaign.id)
      get "/api/v1/characters/#{@brick.id}/sites", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body[0]).to eq(JSON.parse(SiteSerializer.new(@site).to_json))
    end
  end

  describe "POST /api/v1/characters/:character_id/sites" do
    it "attunes a character to a site" do
      @site = @campaign.sites.create!(name: "Manly Steel Mill")
      post "/api/v1/characters/#{@brick.id}/sites", headers: @headers, params: {
        site: {
          id: @site.id
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Manly Steel Mill")
      expect(@brick.reload.sites.count).to eq(1)
    end

    it "creates a site for a character by name" do
      post "/api/v1/characters/#{@brick.id}/sites", headers: @headers, params: {
        site: {
          name: "Manly Steel Mill"
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Manly Steel Mill")
      expect(@brick.reload.sites.count).to eq(1)
    end
  end

  describe "DELETE /api/v1/characters/:character_id/sites/:id" do
    it "destroys a site" do
      @site = @brick.sites.create!(name: "Manly Steel Mill", campaign_id: @campaign.id)
      delete "/api/v1/characters/#{@brick.id}/sites/#{@site.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(@brick.reload.sites).to be_empty
      expect(@site.reload).to be_present
    end
  end
end
