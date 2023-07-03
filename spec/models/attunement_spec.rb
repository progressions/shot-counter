require 'rails_helper'

RSpec.describe Attunement, type: :model do
  let!(:user) { User.create!(email: "email@example.com", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(title: "Action Movie") }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }
  let(:site) { Site.create!(name: "Site", campaign: action_movie) }

  describe "validations" do
    it "validates uniqueness of character to site" do
      expect(Attunement.create(character: brick, site: site)).to be_valid
      expect(Attunement.create(character: brick, site: site)).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to a character" do
      expect(Attunement.create(character: brick, site: site).character).to eq(brick)
    end

    it "belongs to a site" do
      expect(Attunement.create(character: brick, site: site).site).to eq(site)
    end
  end
end
