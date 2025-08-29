require 'rails_helper'

RSpec.describe Campaign, type: :model do
  let!(:user) { User.create!(email: "email@example.com", first_name: "John", last_name: "Doe", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }

  describe "validations" do
    it "requires a name" do
      expect(Campaign.create(name: nil)).to be_invalid
    end
  end

  describe "associations" do
    it "has many characters" do
      expect(action_movie.characters).to eq([brick])
    end

    it "has many weapons" do
      weapon = action_movie.weapons.create!(name: "Sword", damage: "10")
      expect(action_movie.weapons).to eq([weapon])
    end

    it "has many players" do
      action_movie.users << user
      expect(action_movie.users).to eq([user])
    end

    it "has many campaign_memberships" do
      action_movie.users << user
      expect(action_movie.campaign_memberships).to eq([user.campaign_memberships.first])
    end

    it "has many fights" do
      fight = Fight.create!(name: "Fight", campaign: action_movie)
      expect(action_movie.fights).to eq([fight])
    end

    it "has many vehicles" do
      vehicle = Vehicle.create!(name: "Car", campaign: action_movie)
      expect(action_movie.vehicles).to eq([vehicle])
    end

    it "has many invitations" do
      invitation = Invitation.create!(email: "invite@example.com", campaign: action_movie, user: user)
      expect(action_movie.invitations).to eq([invitation])
    end

    it "has many schticks" do
      schtick = Schtick.create!(name: "Schtick", campaign: action_movie, category: "Guns")
      expect(action_movie.schticks).to eq([schtick])
    end

    it "has many parties" do
      party = Party.create!(name: "Party", campaign: action_movie)
      expect(action_movie.parties).to eq([party])
    end

    it "has many sites" do
      site = Site.create!(name: "Site", campaign: action_movie)
      expect(action_movie.sites).to eq([site])
    end

    it "has many factions" do
      faction = Faction.create!(name: "Faction", campaign: action_movie)
      expect(action_movie.factions).to eq([faction])
    end
  end
end
