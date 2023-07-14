require 'rails_helper'

RSpec.describe Mook, type: :model do
  let!(:user) { User.create!(email: "email@example.com", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let!(:fight) { Fight.create!(name: "Fight", campaign: action_movie) }
  let(:grunts) { Character.create!(name: "Grunts", campaign: action_movie, action_values: { "Type" => "Mook", "MainAttack" => "Guns", "Guns" => 9, "Defense" => 13, "Speed" => 6 }) }
  let(:trucks) { Vehicle.create!(name: "Trucks", campaign: action_movie, action_values: { "Type" => "Mook", "Acceleration" => 6 }) }

  describe "validations" do
    it "requires a character or vehicle" do
      mook = Mook.new(shot: Shot.new)
      expect(mook).not_to be_valid
      expect(mook.errors[:character]).to include("can't be blank")
      expect(mook.errors[:vehicle]).to include("can't be blank")
    end

    it "requires a vehicle or a character" do
      mook = Mook.new(shot: Shot.new(vehicle: trucks))
      expect(mook).to be_valid
    end
  end

  describe "associations" do
    it "belongs to a shot" do
      mook = Mook.new(shot: Shot.new)
      expect(mook).to respond_to(:shot)
    end

    it "belongs to a character" do
      mook = Mook.new(shot: Shot.new(character: grunts))
      expect(mook).to respond_to(:character)
    end

    it "belongs to a vehicle" do
      mook = Mook.new(shot: Shot.new(vehicle: trucks))
      expect(mook).to respond_to(:vehicle)
    end
  end
end
