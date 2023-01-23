require 'rails_helper'

RSpec.describe "Schticks", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com", confirmed_at: Time.now)
    @campaign = @gamemaster.campaigns.create!(title: "Adventure")
    @fight = @campaign.fights.create!(name: "Big Brawl")
    @brick = Character.create!(name: "Brick Manly", action_values: { "Type" => "PC" }, campaign_id: @campaign.id)
    @boss = Character.create!(name: "Ugly Shing", action_values: { "Type" => "Boss" }, campaign_id: @campaign.id)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
  end

  describe "GET /api/v1/schticks" do
    it "gets all the schticks" do
      @blam = @campaign.schticks.create!(title: "Blam Blam Epigram", description: "Say a pithy phrase before firing a shot.")
      get "/api/v1/schticks", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body).to eq([@blam.as_json])
    end
  end

  describe "POST /api/v1/schticks" do
    it "creates a schtick" do
      post "/api/v1/schticks", headers: @headers, params: {
        schtick: {
          title: "Blam Blam Epigram",
          description: "Say a pithy phrase before firing a shot."
        }
      }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
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
