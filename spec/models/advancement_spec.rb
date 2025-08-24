require 'rails_helper'

RSpec.describe Advancement, type: :model do
  let!(:user) { User.create!(email: "email@example.com", first_name: "Test", last_name: "User", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }

  describe "validations" do
    it "must have character" do
      expect(Advancement.create(character: nil, description: "Strength")).to be_invalid
    end

    it "doesn't need description" do
      expect(Advancement.create(character: brick, description: nil)).to be_valid
    end
  end
end
