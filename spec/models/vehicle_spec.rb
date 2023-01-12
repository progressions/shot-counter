require "rails_helper"

RSpec.describe Vehicle, type: :model do
  it "sets default action values" do
    truck = Vehicle.create!(name: "Truck")
    expect(truck.action_values).to eq(Vehicle::DEFAULT_ACTION_VALUES)
  end

  it "sets integer values if you try to save strings" do
    truck = Vehicle.create!(name: "Truck")
    truck.action_values["Acceleration"] = "8"
    truck.save!
    expect(truck.action_values["Acceleration"]).to eq(8)
  end
end
