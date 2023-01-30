require 'rails_helper'

RSpec.describe "Api::V1::Sites", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com", confirmed_at: Time.now)
    @campaign = @gamemaster.campaigns.create!(title: "Adventure")
    @brick = Character.create!(name: "Brick Manly", action_values: { "Type" => "PC" }, campaign_id: @campaign.id)
    @boss = Character.create!(name: "Ugly Shing", action_values: { "Type" => "Boss" }, campaign_id: @campaign.id)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
  end

  describe "GET /api/v1/characters/:character_id/sites" do
    it "gets all of a character's sites" do
      @site = @brick.sites.create!(description: "Manly Steel Mill")
      get "/api/v1/characters/#{@brick.id}/sites", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body).to eq(JSON.parse([@site].to_json))
    end
  end

  describe "POST /api/v1/characters/:character_id/sites" do
    it "creates an site for a character" do
      post "/api/v1/characters/#{@brick.id}/sites", headers: @headers, params: {
        site: {
          description: "Manly Steel Mill"
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["description"]).to eq("Manly Steel Mill")
      expect(@brick.reload.sites.count).to eq(1)
    end
  end

  describe "GET /api/v1/characters/:character_id/sites/:id" do
    it "gets an site" do
      @site = @brick.sites.create!(description: "Manly Steel Mill")
      get "/api/v1/characters/#{@brick.id}/sites/#{@site.id}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body).to eq(JSON.parse(@site.to_json))
    end
  end

  describe "PATCH /api/v1/characters/:character_id/sites/:id" do
    it "updates an site" do
      @site = @brick.sites.create!(description: "Manly Mill")
      patch "/api/v1/characters/#{@brick.id}/sites/#{@site.id}", headers: @headers,
        params: {
          site: {
            description: "Manly Steel Mill"
          }
        }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body).to eq(JSON.parse(@site.reload.to_json))
    end
  end

  describe "DELETE /api/v1/characters/:character_id/sites/:id" do
    it "destroys an site" do
      @site = @brick.sites.create!(description: "Manly Steel Mill")
      delete "/api/v1/characters/#{@brick.id}/sites/#{@site.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(@brick.reload.sites).to be_empty
    end
  end


  def set_current_campaign(user, campaign)
    redis = Redis.new
    user_info = {
      "campaign_id" => campaign&.id
    }
    redis.set("user_#{user.id}", user_info.to_json)
  end
end
