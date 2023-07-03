require "rails_helper"

RSpec.describe Character, type: :model do
  before(:each) do
    @user = User.create!(email: "email@example.com")
    @action_movie = @user.campaigns.create!(name: "Action Movie")
  end

  it "sets default action values" do
    brick = Character.create!(name: "Brick Manly", campaign: @action_movie)
    expect(brick.action_values).to eq(Character::DEFAULT_ACTION_VALUES)
  end

  it "sets integer values if you try to save strings" do
    brick = Character.create!(name: "Brick Manly", campaign: @action_movie)
    brick.action_values["Guns"] = "14"
    brick.save!
    expect(brick.action_values["Guns"]).to eq(14)
    expect(brick.action_values["MainAttack"]).to eq("Guns")
  end
end
