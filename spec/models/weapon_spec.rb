require 'rails_helper'

RSpec.describe Weapon, type: :model do
  let!(:user) { User.create!(email: "email@example.com", first_name: "Test", last_name: "User", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }

  describe "validations" do
    it "requires a name" do
      weapon = action_movie.weapons.new(name: "", damage: "7")
      weapon.valid?
      expect(weapon.errors).to have_key(:name)
    end

    it "requires a damage" do
      weapon = action_movie.weapons.new(name: "Fists", damage: "")
      weapon.valid?
      expect(weapon.errors).to have_key(:damage)
    end

    it "requires a campaign" do
      weapon = Weapon.new
      weapon.valid?
      expect(weapon.errors).to have_key(:campaign)
    end
  end

  describe "associations" do
    it "belongs to a character" do
      weapon = action_movie.weapons.create!(name: "Fists", damage: "7")
      brick.weapons << weapon
      expect(weapon.characters).to include(brick)
    end

    it "belongs to a campaign" do
      weapon = action_movie.weapons.create!(name: "Fists", damage: "7")
      expect(weapon.campaign).to eq(action_movie)
    end
  end

  describe "uniqueness" do
    it "requires a unique name for a campaign" do
      action_movie.weapons.create!(name: "Fists", damage: "7")
      weapon = action_movie.weapons.new(name: "Fists", damage: "7")
      weapon.valid?
      expect(weapon.errors).to have_key(:name)
    end
  end
end
