require 'rails_helper'

RSpec.describe "Automatic Milestone Tracking", type: :model do
  include ActiveSupport::Testing::TimeHelpers
  let!(:user) { User.create!(email: "gamemaster@example.com", first_name: "Game", last_name: "Master", confirmed_at: Time.now, gamemaster: true) }
  let!(:campaign) { user.campaigns.create!(name: "Test Campaign") }
  let!(:onboarding_progress) { user.onboarding_progress || user.create_onboarding_progress! }

  describe "when creating a Character" do
    it "sets first_character_created_at timestamp" do
      expect(onboarding_progress.first_character_created_at).to be_nil
      
      character = campaign.characters.create!(name: "Test Character", user: user)
      
      expect(onboarding_progress.reload.first_character_created_at).to be_within(1.second).of(Time.current)
    end

    it "does not overwrite existing timestamp (idempotent)" do
      original_timestamp = 2.hours.ago
      onboarding_progress.update!(first_character_created_at: original_timestamp)

      campaign.characters.create!(name: "Another Character", user: user)

      expect(onboarding_progress.reload.first_character_created_at).to eq(original_timestamp)
    end
  end

  describe "when creating a Fight" do
    it "sets first_fight_created_at timestamp" do
      expect(onboarding_progress.first_fight_created_at).to be_nil
      
      fight = campaign.fights.create!(name: "Test Fight")
      
      expect(onboarding_progress.reload.first_fight_created_at).to be_within(1.second).of(Time.current)
    end
  end

  describe "when creating a Faction" do
    it "sets first_faction_created_at timestamp" do
      expect(onboarding_progress.first_faction_created_at).to be_nil
      
      faction = campaign.factions.create!(name: "Test Faction")
      
      expect(onboarding_progress.reload.first_faction_created_at).to be_within(1.second).of(Time.current)
    end
  end

  describe "when creating a Party" do
    it "sets first_party_created_at timestamp" do
      expect(onboarding_progress.first_party_created_at).to be_nil
      
      party = campaign.parties.create!(name: "Test Party")
      
      expect(onboarding_progress.reload.first_party_created_at).to be_within(1.second).of(Time.current)
    end
  end

  describe "when creating a Site" do
    it "sets first_site_created_at timestamp" do
      expect(onboarding_progress.first_site_created_at).to be_nil
      
      site = campaign.sites.create!(name: "Test Site")
      
      expect(onboarding_progress.reload.first_site_created_at).to be_within(1.second).of(Time.current)
    end
  end

  describe "multiple entity creation" do
    it "tracks each milestone independently" do
      # All timestamps should be nil initially
      expect(onboarding_progress.first_character_created_at).to be_nil
      expect(onboarding_progress.first_fight_created_at).to be_nil
      expect(onboarding_progress.first_faction_created_at).to be_nil

      # Create entities at different times
      character_time = Time.current
      campaign.characters.create!(name: "Test Character", user: user)
      onboarding_progress.reload

      travel 1.minute
      fight_time = Time.current
      campaign.fights.create!(name: "Test Fight")
      onboarding_progress.reload

      travel 1.minute
      faction_time = Time.current
      campaign.factions.create!(name: "Test Faction")
      onboarding_progress.reload

      # Verify each timestamp matches creation time (need to account for travel time)
      expect(onboarding_progress.first_character_created_at).to be_within(1.second).of(character_time)
      expect(onboarding_progress.first_fight_created_at).to be_within(1.second).of(fight_time)
      expect(onboarding_progress.first_faction_created_at).to be_within(1.second).of(faction_time)
      
      travel_back
    end
  end

  describe "different users" do
    let!(:other_user) { User.create!(email: "other@example.com", first_name: "Other", last_name: "User", confirmed_at: Time.now, gamemaster: true) }
    let!(:other_campaign) { other_user.campaigns.create!(name: "Other Campaign") }
    let!(:other_progress) { other_user.onboarding_progress || other_user.create_onboarding_progress! }

    it "only tracks milestones for the campaign owner" do
      expect(onboarding_progress.first_character_created_at).to be_nil
      expect(other_progress.first_character_created_at).to be_nil

      # Create character in first user's campaign
      campaign.characters.create!(name: "Test Character", user: user)

      expect(onboarding_progress.reload.first_character_created_at).to be_present
      expect(other_progress.reload.first_character_created_at).to be_nil
    end
  end
end