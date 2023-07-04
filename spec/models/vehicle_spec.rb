require "rails_helper"

RSpec.describe Vehicle, type: :model do
  before(:each) do
    @user = User.create!(email: "email@example.com")
    @action_movie = @user.campaigns.create!(name: "Action Movie")
  end

  it "sets default action values" do
    truck = Vehicle.create!(name: "Truck", campaign_id: @action_movie.id)
    expect(truck.action_values).to eq(Vehicle::DEFAULT_ACTION_VALUES)
  end

  it "sets integer values if you try to save strings" do
    truck = Vehicle.create!(name: "Truck", campaign_id: @action_movie.id)
    truck.action_values["Acceleration"] = "8"
    truck.save!
    expect(truck.action_values["Acceleration"]).to eq(8)
  end

  describe "associations" do
    it "belongs to a campaign" do
      truck = Vehicle.create!(name: "Truck", campaign_id: @action_movie.id)
      expect(truck.campaign).to eq(@action_movie)
    end

    it "has many action values" do
      truck = Vehicle.create!(name: "Truck", campaign_id: @action_movie.id)
      expect(truck.action_values).to be_a(Hash)
    end

    it "has many fights" do
      truck = Vehicle.create!(name: "Truck", campaign_id: @action_movie.id)
      fight = @action_movie.fights.create!(name: "Big Brawl")
      fight.vehicles << truck
      expect(truck.fights).to include(fight)
    end

    it "has many vehicle_effects" do
      truck = Vehicle.create!(name: "Truck", campaign_id: @action_movie.id)
      fight = @action_movie.fights.create!(name: "Big Brawl")
      fight.vehicles << truck
      shot = fight.shots.create!(vehicle: truck, shot: 10)
      effect = shot.character_effects.create!(name: "Injured", vehicle: truck)
      expect(truck.character_effects).to include(effect)
    end

    it "has many parties" do
      truck = Vehicle.create!(name: "Truck", campaign_id: @action_movie.id)
      party = @action_movie.parties.create!(name: "The Dragons")
      party.vehicles << truck
      expect(truck.parties).to include(party)
    end
  end

  describe "validations" do
    it "requires a name" do
      truck = Vehicle.new(campaign_id: @action_movie.id)
      expect(truck).to_not be_valid
      expect(truck.errors[:name]).to include("can't be blank")
    end

    it "requires a campaign" do
      truck = Vehicle.new(name: "Truck")
      expect(truck).to_not be_valid
      expect(truck.errors[:campaign]).to include("must exist")
    end

    it "doesn't require a user" do
      truck = Vehicle.new(name: "Truck", campaign_id: @action_movie.id)
      expect(truck).to be_valid
      expect(truck.errors[:user]).to be_empty
    end

    xit "requires valid position" do
      truck = Vehicle.new(name: "Truck", campaign_id: @action_movie.id)
      truck.save
      truck.action_values["Position"] = "Invalid"
      expect(truck).to_not be_valid
      expect(truck.errors[:base]).to include("Position must be one of Near, Far")
    end

    it "creates a faction by name" do
      truck = Vehicle.create!(name: "Truck", campaign_id: @action_movie.id)
      truck.action_values["Faction"] = "Rogues"
      truck.save!
      expect(truck.faction.name).to eq("Rogues")
    end

    it "finds a faction by name" do
      truck = Vehicle.create!(name: "Truck", campaign_id: @action_movie.id)
      rogues = @action_movie.factions.create!(name: "Rogues")
      truck.action_values["Faction"] = "Rogues"
      truck.save!
      expect(truck.faction).to eq(rogues)
    end
  end
end
