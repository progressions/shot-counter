require 'rails_helper'

RSpec.describe "Api::V1::CharacterSchticks", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com", confirmed_at: Time.now)
    @campaign = @gamemaster.campaigns.create!(title: "Adventure")
    @fight = @campaign.fights.create!(name: "Big Brawl")
    @brick = Character.create!(name: "Brick Manly", action_values: { "Type" => "PC" }, campaign_id: @campaign.id)
    @boss = Character.create!(name: "Ugly Shing", action_values: { "Type" => "Boss" }, campaign_id: @campaign.id)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
  end

  describe "GET /api/v1/characters/:all_character_id/schticks" do
    it "gets all the schticks for a character" do
      @blam = @campaign.schticks.create!(title: "Blam Blam Epigram", description: "Say a pithy phrase before firing a shot.")
      @brick.schticks << @blam
      get "/api/v1/characters/#{@brick.id}/schticks", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body).to eq(JSON.parse([@blam].to_json))
    end
  end

  describe "POST /api/v1/characters/:all_character_id/schticks" do
    it "adds a schtick to a character" do
      @blam = @campaign.schticks.create!(title: "Blam Blam Epigram", description: "Say a pithy phrase before firing a shot.")
      post "/api/v1/characters/#{@brick.id}/schticks", headers: @headers, params: {
        schtick: { id: @blam.id }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |s| s["title"] }).to eq(["Blam Blam Epigram"])
      expect(@brick.reload.schticks).to include(@blam)
    end
  end

  describe "DELETE /api/v1/characters/:all_character_id/schticks/:id" do
    it "removes a schtick from a character" do
      @blam = @campaign.schticks.create!(title: "Blam Blam Epigram", description: "Say a pithy phrase before firing a shot.")
      @brick.schticks << @blam
      delete "/api/v1/characters/#{@brick.id}/schticks/#{@blam.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(@brick.reload.schticks).to be_empty
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
