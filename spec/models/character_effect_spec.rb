require 'rails_helper'

RSpec.describe CharacterEffect, type: :model do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com")
    @campaign = @gamemaster.campaigns.create!(title: "Adventure")
    @fight = @campaign.fights.create!(name: "Big Brawl")
    @brick = Character.create!(name: "Brick Manly", campaign_id: @campaign.id)
  end

  it "must belong to a fight" do
    @character_effect = CharacterEffect.new(title: "Bonus", character_id: @brick)
    expect(@character_effect).not_to be_valid
    expect(@character_effect.errors[:fight]).to eq(["must exist"])
  end

  it "must belong to either a character or a vehicle" do
    @character_effect = @fight.character_effects.new(title: "Bonus")
    expect(@character_effect).not_to be_valid
    expect(@character_effect.errors[:character]).to eq(["must be present if vehicle is not set"])
    expect(@character_effect.errors[:vehicle]).to eq(["must be present if character is not set"])
  end
end
