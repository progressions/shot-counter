require 'rails_helper'

RSpec.describe CharacterSchtick, type: :model do
  let!(:user) { User.create!(email: "email@example.com", first_name: "Test", last_name: "User", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }
  let(:schtick) { action_movie.schticks.create!(name: "Schtick", category: "Guns") }

  describe "validations" do
    it "validates uniqueness of character_id and schtick_id" do
      expect(CharacterSchtick.create(character: brick, schtick: schtick)).to be_valid
      expect(CharacterSchtick.create(character: brick, schtick: schtick)).to_not be_valid
    end
  end

  describe "associations" do
    it "belongs to a character" do
      expect(CharacterSchtick.create(character: brick, schtick: schtick).character).to eq(brick)
    end

    it "belongs to a schtick" do
      expect(CharacterSchtick.create(character: brick, schtick: schtick).schtick).to eq(schtick)
    end
  end
end
