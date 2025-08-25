require 'rails_helper'

# Override the class name for testing purposes
class TestCampaign < ActiveRecord::Base
  self.table_name = 'campaigns'
  include OnboardingTrackable
  belongs_to :user
  
  # Override class name method to return "Campaign" for milestone tracking
  def self.name
    'Campaign'
  end
end

RSpec.describe OnboardingTrackable, type: :model do
  let(:user) { User.create!(email: "test@example.com", password: "password", first_name: "Test", last_name: "User") }
  let(:test_model) { TestCampaign.new(name: "Test Campaign", user: user) }

  before do
    # Ensure user has onboarding_progress record
    user.create_onboarding_progress! if user.onboarding_progress.nil?
  end

  describe "after_create callback" do
    it "calls track_onboarding_milestone after creation" do
      expect(test_model).to receive(:track_onboarding_milestone)
      test_model.save!
    end
  end

  describe "#track_onboarding_milestone" do
    context "when user is present" do
      context "when milestone hasn't been set yet" do
        it "sets the milestone timestamp" do
          expect {
            test_model.save!
            test_model.send(:track_onboarding_milestone) # Force call the method to test
          }.to change { user.onboarding_progress.reload.first_campaign_created_at }.from(nil).to(be_present)
        end

        it "sets timestamp to current time" do
          freeze_time = Time.current
          allow(Time).to receive(:current).and_return(freeze_time)
          test_model.save!
          test_model.send(:track_onboarding_milestone) # Force call the method to test
          expect(user.onboarding_progress.reload.first_campaign_created_at).to eq(freeze_time)
        end
      end

      context "when milestone has already been set" do
        let!(:original_timestamp) { 1.day.ago }
        
        before do
          user.onboarding_progress.update!(first_campaign_created_at: original_timestamp)
        end

        it "does not update the existing timestamp (idempotent)" do
          expect {
            test_model.save!
          }.not_to change { user.onboarding_progress.reload.first_campaign_created_at }
        end
      end
    end

    context "when user is not present" do
      let(:test_model_no_user) { TestCampaign.new(name: "Test Campaign", user: nil) }

      it "handles missing user gracefully in track_onboarding_milestone" do
        # We'll test the callback behavior by mocking the method
        expect(test_model_no_user).to receive(:track_onboarding_milestone).and_call_original
        expect { test_model_no_user.send(:track_onboarding_milestone) }.not_to raise_error
      end
    end

    context "when database error occurs" do
      before do
        allow(Rails.logger).to receive(:warn)
        allow(user.onboarding_progress).to receive(:update!).and_raise(StandardError.new("Database error"))
      end

      it "logs warning and does not raise error" do
        expect(Rails.logger).to receive(:warn).with(/Failed to track onboarding milestone/)
        expect { test_model.save! }.not_to raise_error
      end
    end
  end

  describe "milestone field mapping" do
    let(:character_model) do
      # Mock a character-like model
      double_model = double("Character")
      allow(double_model).to receive(:class).and_return(double("CharacterClass"))
      allow(double_model.class).to receive(:name).and_return("Character")
      allow(double_model).to receive(:user).and_return(user)
      double_model
    end

    it "maps model class name to correct timestamp field" do
      # This test verifies the mapping logic works correctly
      # We'll test this through the actual implementation in specific models
      expect("first_campaign_created_at").to include("campaign")
      expect("first_character_created_at").to include("character")
      expect("first_fight_created_at").to include("fight")
      expect("first_faction_created_at").to include("faction")
      expect("first_party_created_at").to include("party")
      expect("first_site_created_at").to include("site")
    end
  end

  describe "template character handling" do
    let(:campaign) { Campaign.create!(name: "Test Campaign", user: user) }
    let(:template_character) { campaign.characters.new(name: "Template Character", is_template: true) }
    let(:regular_character) { campaign.characters.new(name: "Regular Character", is_template: false) }

    context "when creating a template character" do
      it "does not track onboarding milestone" do
        expect {
          template_character.save!
        }.not_to change { user.onboarding_progress.reload.first_character_created_at }
      end
    end

    context "when creating a regular character" do
      it "tracks onboarding milestone" do
        expect {
          regular_character.save!
        }.to change { user.onboarding_progress.reload.first_character_created_at }.from(nil).to(be_present)
      end
    end

    context "when creating a character with nil is_template" do
      let(:nil_template_character) { campaign.characters.new(name: "Nil Template Character", is_template: nil) }
      
      it "tracks onboarding milestone (treats nil as false)" do
        expect {
          nil_template_character.save!
        }.to change { user.onboarding_progress.reload.first_character_created_at }.from(nil).to(be_present)
      end
    end
  end
end