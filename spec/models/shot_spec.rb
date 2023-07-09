require 'rails_helper'

RSpec.describe Shot, type: :model do
  before(:each) do
    @gamemaster = User.create!(email: "email@example.com")
    @campaign = @gamemaster.campaigns.create!(name: "Adventure")
    @space = @gamemaster.campaigns.create!(name: "Space")
    @fight = @campaign.fights.create!(name: "Battle")
  end

  it "must have character and fight belong to the same campaign" do
    @brick = @space.characters.create!(name: "Brick Manly")
    @shot = @fight.shots.new(character_id: @brick.id)
    expect(@shot).not_to be_valid
    expect(@shot.errors[:character]).to eq(["must belong to the same campaign as its fight"])
  end

  it "must have vehicle and fight belong to the same campaign" do
    @truck = @space.vehicles.create!(name: "Truck")
    @shot = @fight.shots.new(vehicle_id: @truck.id)
    expect(@shot).not_to be_valid
    expect(@shot.errors[:vehicle]).to eq(["must belong to the same campaign as its fight"])
  end

  it "has one location" do
    @shot = @fight.shots.new
    expect(@shot).to respond_to(:location)
  end
end
