require 'rails_helper'

RSpec.describe Membership, type: :model do
  let!(:user) { User.create!(email: "email@example.com", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(title: "Action Movie") }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }
  let!(:party) { action_movie.parties.create!(name: "Party") }

  describe "validations" do
    it "validates uniqueness of character_id and party_id to campaign_id" do
      expect(Membership.create(character: brick, party: party)).to be_valid
      expect(Membership.create(character: brick, party: party)).to_not be_valid
    end
  end

  describe "associations" do
    it "belongs to a character" do
      expect(Membership.create(character: brick, party: party).character).to eq(brick)
    end

    it "belongs to a party" do
      expect(Membership.create(character: brick, party: party).party).to eq(party)
    end
  end
end
