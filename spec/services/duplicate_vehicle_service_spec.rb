require "rails_helper"

RSpec.describe "DuplicateVehicleService" do
  let(:user) { User.create!(email: "email@example.com", first_name: "Test", last_name: "User") }
  let(:action_movie) { user.campaigns.create!(name: "Action Movie") }

  describe ".duplicate" do
    let!(:vehicle) { action_movie.vehicles.create(name: "Test Vehicle") }
    let(:duplicated_vehicle) { DuplicateVehicleService.duplicate(vehicle) }

    it "creates a new vehicle" do
      expect { duplicated_vehicle }.to change(Vehicle, :count).by(1)
    end

    it "sets the new vehicle's name to the original name with an incremented number" do
      expect(duplicated_vehicle.name).to eq("Test Vehicle (1)")
    end

    it "increments the number again" do
      expect(DuplicateVehicleService.duplicate(vehicle).name).to eq("Test Vehicle (1)")
      expect(DuplicateVehicleService.duplicate(vehicle).name).to eq("Test Vehicle (2)")
    end

    it "sets the new vehicle's user to the original vehicle's user" do
      expect(duplicated_vehicle.user).to eq(vehicle.user)
    end

    it "sets the new vehicle's campaign to the original vehicle's campaign" do
      expect(duplicated_vehicle.campaign).to eq(vehicle.campaign)
    end

    it "sets the new vehicle's action values to the original vehicle's action values" do
      expect(duplicated_vehicle.action_values).to eq(vehicle.action_values)
    end
  end
end
