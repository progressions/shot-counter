require 'rails_helper'

RSpec.describe Location, type: :model do
  let(:gamemaster) { User.create!(email: "email@example.com") }
  let(:action_movie) { gamemaster.campaigns.create!(name: "Action Movie") }
  let(:fight) { action_movie.fights.create!(name: "Battle") }
  let(:brick) { action_movie.characters.create!(name: "Brick") }
  let(:truck) { action_movie.vehicles.create!(name: "Truck") }
  let!(:brick_shot) { fight.shots.create!(character: brick, shot: 12) }
  let!(:truck_shot) { fight.shots.create!(vehicle: truck, shot: 12) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(Location.new(name: "Location", shot: brick_shot)).to be_valid
    end

    it "is not valid without a name" do
      expect(Location.new(name: nil, shot: brick_shot)).to_not be_valid
    end

    it "is not valid without a shot" do
      expect(Location.new(name: "Location", shot: nil)).to_not be_valid
    end

    it "returns character from shot" do
      location = Location.create!(name: "Location", shot: brick_shot)
      expect(location.character).to eq(brick)
      expect(location.vehicle).to be_nil
    end

    it "returns vehicle from shot" do
      location = Location.create!(name: "Location", shot: truck_shot)
      expect(location.character).to be_nil
      expect(location.vehicle).to eq(truck)
    end
  end
end
