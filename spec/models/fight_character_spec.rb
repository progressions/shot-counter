require 'rails_helper'

RSpec.describe FightCharacter, type: :model do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com")
    @campaign = @gamemaster.campaigns.create!(title: "Adventure")
    @space = @gamemaster.campaigns.create!(title: "Space")
    @fight = @campaign.fights.create!(name: "Battle")
  end

  it "must have character and fight belong to the same campaign" do
    @brick = @space.characters.create!(name: "Brick Manly")
    @fight_character = @fight.fight_characters.new(character_id: @brick.id)
    expect(@fight_character).not_to be_valid
    expect(@fight_character.errors[:character]).to eq(["must belong to the same campaign as its fight"])
  end

  it "must have vehicle and fight belong to the same campaign" do
    @truck = @space.vehicles.create!(name: "Truck")
    @fight_character = @fight.fight_characters.new(vehicle_id: @truck.id)
    expect(@fight_character).not_to be_valid
    expect(@fight_character.errors[:vehicle]).to eq(["must belong to the same campaign as its fight"])
  end
end

