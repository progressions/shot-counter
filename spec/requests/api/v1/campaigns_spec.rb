require 'rails_helper'

RSpec.describe "Api::V1::Campaigns", type: :request do
  include ApiHelper

  before(:each) do
    @user = User.create!(email: "email@example.com")
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @user)
  end

  describe "POST /set" do
    it "returns http success" do
      @campaign = @user.campaigns.create!(title: "Action Movie")

      post "/api/v1/campaigns/#{@campaign.id}/set", headers: @headers
      expect(response).to have_http_status(:success)

      redis = Redis.new
      user_info = JSON.parse(redis.get("user_#{@user.id}"))
      expect(user_info["campaign_id"]).to eq(@campaign.id)
    end
  end

end
