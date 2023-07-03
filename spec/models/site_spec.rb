require 'rails_helper'

RSpec.describe Site, type: :model do
  let!(:user) { User.create!(email: "email@example.com", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(title: "Action Movie") }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }

  describe "validations" do
    it "has a name" do
      site = Site.create!(name: "The Cave", campaign: action_movie)
      expect(site.name).to eq("The Cave")
    end

    it "has a campaign" do
      site = Site.create!(name: "The Cave", campaign: action_movie)
      expect(site.campaign).to eq(action_movie)
    end

    it "can have characters" do
      site = Site.create!(name: "The Cave", campaign: action_movie)
      site.characters << brick
      expect(site.characters).to include(brick)
    end
  end

  describe "associations" do
    it "belongs to a campaign" do
      site = Site.create!(name: "The Cave", campaign: action_movie)
      expect(site.campaign).to eq(action_movie)
    end

    it "can have characters" do
      site = Site.create!(name: "The Cave", campaign: action_movie)
      site.characters << brick
      expect(site.characters).to include(brick)
    end
  end
end
