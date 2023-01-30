require 'rails_helper'

RSpec.describe "Api::V1::Advancements", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com", confirmed_at: Time.now)
    @campaign = @gamemaster.campaigns.create!(title: "Adventure")
    @brick = Character.create!(name: "Brick Manly", action_values: { "Type" => "PC" }, campaign_id: @campaign.id)
    @boss = Character.create!(name: "Ugly Shing", action_values: { "Type" => "Boss" }, campaign_id: @campaign.id)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
  end

  describe "GET /api/v1/characters/:character_id/advancements" do
    it "gets all of a character's advancements" do
      @advancement = @brick.advancements.create!(description: "Increased Leadership skill to 13")
      get "/api/v1/characters/#{@brick.id}/advancements", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body).to eq(JSON.parse([@advancement].to_json))
    end
  end

  describe "POST /api/v1/characters/:character_id/advancements" do
    it "creates an advancement for a character" do
      post "/api/v1/characters/#{@brick.id}/advancements", headers: @headers, params: {
        advancement: {
          description: "Increase Leadership"
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["description"]).to eq("Increase Leadership")
      expect(@brick.reload.advancements.count).to eq(1)
    end
  end

  describe "GET /api/v1/characters/:character_id/advancements/:id" do
    it "gets an advancement" do
      @advancement = @brick.advancements.create!(description: "Increased Leadership skill to 13")
      get "/api/v1/characters/#{@brick.id}/advancements/#{@advancement.id}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body).to eq(JSON.parse(@advancement.to_json))
    end
  end

  describe "PATCH /api/v1/characters/:character_id/advancements/:id" do
    it "updates an advancement" do
      @advancement = @brick.advancements.create!(description: "Increased Leadership skill")
      patch "/api/v1/characters/#{@brick.id}/advancements/#{@advancement.id}", headers: @headers,
        params: {
          advancement: {
            description: "Increase Leadership skill to 13"
          }
        }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body).to eq(JSON.parse(@advancement.reload.to_json))
    end
  end

  describe "DELETE /api/v1/characters/:character_id/advancements/:id" do
    it "destroys an advancement" do
      @advancement = @brick.advancements.create!(description: "Increased Leadership skill to 13")
      delete "/api/v1/characters/#{@brick.id}/advancements/#{@advancement.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(@brick.reload.advancements).to be_empty
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
