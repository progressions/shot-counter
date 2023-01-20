require 'rails_helper'

RSpec.describe "CharacterEffects", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com")
    @campaign = @gamemaster.campaigns.create!(title: "Adventure")
    @fight = @campaign.fights.create!(name: "Big Brawl")
    @brick = Character.create!(name: "Brick Manly", campaign_id: @campaign.id)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
  end

  describe "GET /api/v1/character_effects" do
  end
end
