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
end
