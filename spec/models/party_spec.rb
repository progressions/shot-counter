require 'rails_helper'

RSpec.describe Party, type: :model do
  let!(:user) { User.create!(email: "email@example.com") }
  let!(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }
  let(:party) { Party.create!(name: "The Party", campaign: action_movie) }

  it "has a name" do
    expect(party.name).to eq("The Party")
  end

  it "character can join a party" do
    party.characters << brick
    expect(party.characters).to include(brick)
  end

  describe "validations" do
    it "requires a name" do
      party.name = nil
      expect(party).to_not be_valid
    end

    it "requires a unique name within a campaign" do
      party2 = Party.new(name: "The Party", campaign: action_movie)
      expect(party2).to_not be_valid
    end
  end
end
