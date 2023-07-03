require 'rails_helper'

RSpec.describe CampaignMembership, type: :model do
  let!(:user) { User.create!(email: "email@example.com", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(name: "Action Movie") }

  describe "validations" do
    it "requires a user" do
      expect(CampaignMembership.create(user: nil, campaign: action_movie)).to be_invalid
    end

    it "requires a campaign" do
      expect(CampaignMembership.create(user: user, campaign: nil)).to be_invalid
    end

    it "requires a unique user per campaign" do
      CampaignMembership.create(user: user, campaign: action_movie)
      expect(CampaignMembership.create(user: user, campaign: action_movie)).to be_invalid
    end
  end
end
