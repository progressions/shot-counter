require 'rails_helper'

RSpec.describe CharacterEffect, type: :model do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com")
    @campaign = @gamemaster.campaigns.create!(title: "Adventure")
    @fight = @campaign.fights.create!(name: "Big Brawl")
    @brick = Character.create!(name: "Brick Manly", campaign_id: @campaign.id)
    @truck = Vehicle.create!(name: "Truck", campaign_id: @campaign.id)
  end

  it "must belong to a fight" do
    @character_effect = CharacterEffect.new(title: "Bonus", character_id: @brick.id)
    expect(@character_effect).not_to be_valid
    expect(@character_effect.errors[:fight]).to eq(["must exist"])
  end

  it "must belong to either a character or a vehicle" do
    @character_effect = @fight.character_effects.new(title: "Bonus")
    expect(@character_effect).not_to be_valid
    expect(@character_effect.errors[:character]).to eq(["must be present if vehicle is not set"])
    expect(@character_effect.errors[:vehicle]).to eq(["must be present if character is not set"])
  end

  it "must have action_value if change is set" do
    @character_effect = @fight.character_effects.new(title: "Bonus", change: "+1", character_id: @brick.id)
    expect(@character_effect).not_to be_valid
    expect(@character_effect.errors[:action_value]).to eq(["must be present if change is set"])
  end

  it "must have change if action_value is set" do
    @character_effect = @fight.character_effects.new(title: "Bonus", action_value: "MainAttack", character_id: @brick.id)
    expect(@character_effect).not_to be_valid
    expect(@character_effect.errors[:change]).to eq(["must be present if action_value is set"])
  end

  it "must be a valid action_value" do
    @character_effect = @fight.character_effects.new(title: "Bonus", action_value: "Thing", change: "+1", character_id: @brick.id)
    expect(@character_effect).not_to be_valid
    expect(@character_effect.errors[:action_value]).to eq(["must be a valid key"])
  end

  it "must be a valid action_value" do
    @character_effect = @fight.character_effects.new(title: "Bonus", action_value: "Thing", change: "+1", vehicle_id: @truck.id)
    expect(@character_effect).not_to be_valid
    expect(@character_effect.errors[:action_value]).to eq(["must be a valid key"])
  end
end
