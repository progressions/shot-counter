require 'rails_helper'

RSpec.describe Faction, type: :model do
  let!(:user) { User.create!(email: "email@example.com", first_name: "Test", last_name: "User", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }

  describe "validations" do
    it "is valid with a name" do
      faction = Faction.new(name: "The Bad Guys", campaign: action_movie)
      expect(faction).to be_valid
    end

    it "is invalid without a name" do
      faction = Faction.new(campaign: action_movie)
      expect(faction).to be_invalid
    end

    it "is invalid without a campaign" do
      faction = Faction.new(name: "The Bad Guys")
      expect(faction).to be_invalid
    end
  end

  describe "associations" do
    it "belongs to a campaign" do
      faction = Faction.new(name: "The Bad Guys", campaign: action_movie)
      expect(faction.campaign).to eq(action_movie)
    end

    it "has many characters" do
      faction = Faction.new(name: "The Bad Guys", campaign: action_movie)
      faction.characters << brick
      expect(faction.characters).to include(brick)
    end
  end
end
