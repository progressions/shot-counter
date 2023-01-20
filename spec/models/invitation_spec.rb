require 'rails_helper'

RSpec.describe Invitation, type: :model do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com")
    @campaign = @gamemaster.campaigns.create!(title: "Adventure")
  end

  it "can't have remaining_count greater than maximum_count" do
    @invitation = @campaign.invitations.new(user_id: @gamemaster.id, campaign_id: @campaign.id, maximum_count: 10, remaining_count: 11)
    expect(@invitation).not_to be_valid
    expect(@invitation.errors[:remaining_count]).to eq(["cannot exceed maximum_count"])
  end

  it "must have valid email if email is present" do
    @invitation = @campaign.invitations.new(email: "alice@email.com", user_id: @gamemaster.id, campaign_id: @campaign.id)
    expect(@invitation).to be_valid
  end

  it "returns error with invalid email" do
    @invitation = @campaign.invitations.new(email: "alice", user_id: @gamemaster.id, campaign_id: @campaign.id)
    expect(@invitation).not_to be_valid
    expect(@invitation.errors[:email]).to eq(["is invalid"])
  end
end
