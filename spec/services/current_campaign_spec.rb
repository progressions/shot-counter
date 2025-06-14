require 'rails_helper'

RSpec.describe CurrentCampaign do
  let(:user) { User.create!(email: "email@example.com") }
  let(:action_movie) { user.campaigns.create!(name: "Action Movie") }

  before(:each) do
    # Clear Redis before each test to ensure a clean state
    CurrentCampaign.send(:redis).flushdb
  end

  describe "get" do
    it "returns the current campaign for a user" do
      user.current_campaign = action_movie
      user.save

      CurrentCampaign.get(user: user)

      expect(CurrentCampaign.get(user: user)).to eq(action_movie)
    end

    it "returns nil if no current campaign is set for a user" do
      expect(CurrentCampaign.get(user: user)).to be_nil
    end

    it "returns the current campaign from Redis for a server" do
      CurrentCampaign.set(user: user, server_id: "server_123", campaign: action_movie)
      expect(CurrentCampaign.get(server_id: "server_123")).to eq(action_movie)
    end

    it "returns nil if no campaign is found in Redis for a server" do
      expect(CurrentCampaign.get(server_id: "non_existent_server")).to be_nil
    end
  end

  describe "set" do
    it "sets the current campaign for a user" do
      CurrentCampaign.set(user: user, campaign: action_movie)

      expect(user.reload.current_campaign).to eq(action_movie)
    end

    it "clears the current campaign for a user if nil is passed" do
      user.current_campaign = action_movie
      user.save
      CurrentCampaign.set(user: user, campaign: nil)
      expect(user.reload.current_campaign).to be_nil
    end

    it "sets the current campaign in Redis for a server" do
      CurrentCampaign.set(user: user, server_id: "server_456", campaign: action_movie)

      json = CurrentCampaign.send(:redis).get("current_campaign:server_456")
      expect(json).to be_present

      campaign_info = JSON.parse(json)
      expect(campaign_info["campaign_id"]).to eq(action_movie.id)
    end
  end
end
