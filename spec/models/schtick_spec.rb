require 'rails_helper'

RSpec.describe Schtick, type: :model do
  let!(:user) { User.create!(email: "email@example.com", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let(:brick) { Character.create!(name: "Brick Manly", action_values: { "Archetype" => "Everyday Hero" }, campaign: action_movie) }

  describe "validations" do
    it "requires a name" do
      schtick = Schtick.new
      schtick.valid?
      expect(schtick.errors[:name]).to include("can't be blank")
    end

    it "requires a campaign" do
      schtick = Schtick.new
      schtick.valid?
      expect(schtick.errors[:campaign]).to include("must exist")
    end

    it "category must be in the list" do
      schtick = Schtick.new(category: "Not a real category")
      schtick.valid?
      expect(schtick.errors[:category]).to include("is not included in the list")
    end
  end

  describe "associations" do
    it "belongs to a campaign" do
      schtick = Schtick.new(name: "Schtick", campaign: action_movie)
      expect(schtick.campaign).to eq(action_movie)
    end

    it "has a prerequisite" do
      schtick = Schtick.new(name: "Schtick", campaign: action_movie)
      schtick.prerequisite = Schtick.new(name: "Prerequisite", campaign: action_movie)
      expect(schtick.prerequisite.name).to eq("Prerequisite")
    end

    it "has characters" do
      schtick = Schtick.new(name: "Schtick", campaign: action_movie)
      schtick.characters << brick
      expect(schtick.characters.first.name).to eq("Brick Manly")
    end
  end

  describe ".for_archetype" do
    let!(:schtick) { Schtick.create!(name: "Schtick", campaign: action_movie, archetypes: ["Exorcist Monk", "Everyday Hero"]) }

    it "returns schticks for an archetype" do
      expect(Schtick.for_archetype("Everyday Hero")).to include(schtick)
    end
  end
end
