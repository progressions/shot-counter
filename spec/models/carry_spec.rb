require 'rails_helper'

RSpec.describe Carry, type: :model do
  let!(:user) { User.create!(email: "email@example.com", first_name: "Test", last_name: "User", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }
  let(:weapon) { Weapon.create!(name: "Sword", damage: "10", campaign: action_movie) }

  describe "validations" do
    it "allows multiple carries of the same weapon" do
      expect(Carry.create(character: brick, weapon: weapon)).to be_valid
      expect(Carry.create(character: brick, weapon: weapon)).to be_valid
    end
  end

  describe "associations" do
    it "belongs to a character" do
      expect(Carry.create(character: brick, weapon: weapon).character).to eq(brick)
    end

    it "belongs to a weapon" do
      expect(Carry.create(character: brick, weapon: weapon).weapon).to eq(weapon)
    end
  end
end
