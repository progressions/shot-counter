require 'rails_helper'

RSpec.describe OnboardingProgress, type: :model do
  let(:user) { User.create!(email: "test@example.com", password: "password", first_name: "Test", last_name: "User") }
  let(:onboarding_progress) { OnboardingProgress.new(user: user) }

  describe "associations" do
    it "belongs to a user" do
      expect(onboarding_progress.user).to eq(user)
    end
  end

  describe "validations" do
    it "is valid with a user" do
      expect(onboarding_progress).to be_valid
    end

    it "is invalid without a user" do
      onboarding_progress.user = nil
      expect(onboarding_progress).to_not be_valid
      expect(onboarding_progress.errors[:user]).to include("must exist")
    end
  end

  describe "#all_milestones_complete?" do
    it "returns false when no milestones are completed" do
      expect(onboarding_progress.all_milestones_complete?).to be false
    end

    it "returns false when some milestones are completed" do
      onboarding_progress.first_campaign_created_at = Time.current
      onboarding_progress.first_character_created_at = Time.current
      expect(onboarding_progress.all_milestones_complete?).to be false
    end

    it "returns true when all core milestones are completed" do
      timestamp = Time.current
      onboarding_progress.first_campaign_created_at = timestamp
      onboarding_progress.first_character_created_at = timestamp
      onboarding_progress.first_fight_created_at = timestamp
      onboarding_progress.first_faction_created_at = timestamp
      onboarding_progress.first_party_created_at = timestamp
      onboarding_progress.first_site_created_at = timestamp
      expect(onboarding_progress.all_milestones_complete?).to be true
    end
  end

  describe "#onboarding_complete?" do
    let(:complete_progress) do
      timestamp = Time.current
      OnboardingProgress.new(
        user: user,
        first_campaign_created_at: timestamp,
        first_character_created_at: timestamp,
        first_fight_created_at: timestamp,
        first_faction_created_at: timestamp,
        first_party_created_at: timestamp,
        first_site_created_at: timestamp,
        congratulations_dismissed_at: timestamp)
    end

    it "returns false when milestones are incomplete" do
      expect(onboarding_progress.onboarding_complete?).to be false
    end

    it "returns false when milestones are complete but congratulations not dismissed" do
      timestamp = Time.current
      onboarding_progress.first_campaign_created_at = timestamp
      onboarding_progress.first_character_created_at = timestamp
      onboarding_progress.first_fight_created_at = timestamp
      onboarding_progress.first_faction_created_at = timestamp
      onboarding_progress.first_party_created_at = timestamp
      onboarding_progress.first_site_created_at = timestamp
      onboarding_progress.congratulations_dismissed_at = nil
      expect(onboarding_progress.onboarding_complete?).to be false
    end

    it "returns true when all milestones are complete and congratulations dismissed" do
      expect(complete_progress.onboarding_complete?).to be true
    end
  end

  describe "#ready_for_congratulations?" do
    it "returns false when milestones are incomplete" do
      expect(onboarding_progress.ready_for_congratulations?).to be false
    end

    it "returns true when all milestones complete but congratulations not dismissed" do
      timestamp = Time.current
      onboarding_progress.first_campaign_created_at = timestamp
      onboarding_progress.first_character_created_at = timestamp
      onboarding_progress.first_fight_created_at = timestamp
      onboarding_progress.first_faction_created_at = timestamp
      onboarding_progress.first_party_created_at = timestamp
      onboarding_progress.first_site_created_at = timestamp
      onboarding_progress.congratulations_dismissed_at = nil
      expect(onboarding_progress.ready_for_congratulations?).to be true
    end

    it "returns false when congratulations already dismissed" do
      timestamp = Time.current
      onboarding_progress.first_campaign_created_at = timestamp
      onboarding_progress.first_character_created_at = timestamp
      onboarding_progress.first_fight_created_at = timestamp
      onboarding_progress.first_faction_created_at = timestamp
      onboarding_progress.first_party_created_at = timestamp
      onboarding_progress.first_site_created_at = timestamp
      onboarding_progress.congratulations_dismissed_at = timestamp
      expect(onboarding_progress.ready_for_congratulations?).to be false
    end
  end

  describe "#next_milestone" do
    it "returns campaign as first milestone when none completed" do
      next_milestone = onboarding_progress.next_milestone
      expect(next_milestone[:key]).to eq('campaign')
      expect(next_milestone[:timestamp_field]).to eq(:first_campaign_created_at)
    end

    it "returns character as next milestone when only campaign completed" do
      onboarding_progress.first_campaign_created_at = Time.current
      next_milestone = onboarding_progress.next_milestone
      expect(next_milestone[:key]).to eq('character')
      expect(next_milestone[:timestamp_field]).to eq(:first_character_created_at)
    end

    it "returns nil when all milestones are completed" do
      timestamp = Time.current
      onboarding_progress.first_campaign_created_at = timestamp
      onboarding_progress.first_character_created_at = timestamp
      onboarding_progress.first_fight_created_at = timestamp
      onboarding_progress.first_faction_created_at = timestamp
      onboarding_progress.first_party_created_at = timestamp
      onboarding_progress.first_site_created_at = timestamp
      expect(onboarding_progress.next_milestone).to be_nil
    end
  end
end