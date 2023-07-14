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

  it "destroys its location when it is destroyed" do
    @shot = @fight.shots.create!(character: @campaign.characters.create!(name: "Brick Manly"))
    @location = @shot.create_location!(name: "Location")
    expect { @shot.destroy }.to change { Location.count }.by(-1)
  end

  it "destroys its mook when it is destroyed" do
    @shot = @fight.shots.create!(character: @campaign.characters.create!(name: "Mook"))
    @mook = @shot.create_mook!(count: 10)
    expect { @shot.destroy }.to change { Mook.count }.by(-1)
  end
end
