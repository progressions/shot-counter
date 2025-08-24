require 'rails_helper'

RSpec.describe Effect, type: :model do
  let!(:user) { User.create!(email: "email@example.com", first_name: "Test", last_name: "User", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }
  let(:fight) { Fight.create!(campaign: action_movie, name: "Test Fight") }

  describe "validations" do
    it "requires a severity" do
      effect = Effect.new
      effect.valid?
      expect(effect.errors[:severity]).to include("can't be blank")
    end

    it "requires a valid severity" do
      effect = Effect.new(severity: "invalid")
      effect.valid?
      expect(effect.errors[:severity]).to include("is not included in the list")
    end
  end

  describe "associations" do
    it "belongs to a fight" do
      effect = fight.effects.create!(severity: "info")
      expect(effect.fight).to eq(fight)
    end

    it "belongs to a user" do
      effect = fight.effects.create!(severity: "info", user: user)
      expect(effect.user).to eq(user)
    end
  end
end
