require 'rails_helper'

RSpec.describe "Campaign Seeding with db/seeds Content", type: :model do
  # This test verifies that new campaigns are properly seeded with content
  # from the Master Template Campaign that's created by db/seeds.rb
  
  before(:all) do
    # Ensure we have clean test database with seed data
    Rails.application.load_seed
  end

  let(:master_template) { Campaign.find_by(is_master_template: true) }
  let(:gamemaster) { User.find_by(email: 'progressions@gmail.com') }

  describe "Master Template Campaign from seeds" do
    it "exists with proper content" do
      expect(master_template).to be_present
      expect(master_template.name).to eq('Master Template Campaign')
      
      # Verify it has the starter content we added
      expect(master_template.characters.where(is_template: true).count).to be >= 4
      expect(master_template.schticks.count).to be >= 6
      expect(master_template.weapons.count).to be >= 5
      expect(master_template.junctures.count).to be >= 4
      expect(master_template.factions.count).to be >= 4
    end

    it "has characters with proper associations" do
      template_characters = master_template.characters.where(is_template: true)
      
      template_characters.each do |character|
        expect(character.schticks.count).to be >= 1
        expect(character.weapons.count).to be >= 1
      end
    end

    it "has junctures with faction associations" do
      master_template.junctures.each do |juncture|
        expect(juncture.faction).to be_present
      end
    end
  end

  describe "New campaign seeding" do
    let(:new_campaign) do
      Campaign.create!(
        name: "Test Campaign #{Time.current.to_i}",
        description: "Testing seeding from db/seeds content",
        user: gamemaster
      )
    end

    it "automatically seeds new campaigns with Master Template content" do
      # The campaign should be created without content initially
      expect(new_campaign.seeded_at).to be_nil
      expect(new_campaign.characters.count).to eq(0)
      
      # Execute the seeding synchronously
      result = CampaignSeederService.seed_campaign(new_campaign)
      expect(result).to be true
      
      # Reload and verify seeding completed
      new_campaign.reload
      expect(new_campaign.seeded_at).to be_present
      
      # Verify all content types were copied
      expect(new_campaign.characters.count).to eq(master_template.characters.where(is_template: true).count)
      expect(new_campaign.schticks.count).to eq(master_template.schticks.count)
      expect(new_campaign.weapons.count).to eq(master_template.weapons.count)
      expect(new_campaign.junctures.count).to eq(master_template.junctures.count)
      expect(new_campaign.factions.count).to eq(master_template.factions.count)
    end

    it "copies characters with their associations intact" do
      CampaignSeederService.seed_campaign(new_campaign)
      new_campaign.reload
      
      # Each character should have schticks and weapons
      new_campaign.characters.each do |character|
        expect(character.schticks.count).to be >= 1
        expect(character.weapons.count).to be >= 1
        
        # Verify the schticks and weapons belong to the new campaign
        character.schticks.each do |schtick|
          expect(schtick.campaign).to eq(new_campaign)
        end
        
        character.weapons.each do |weapon|
          expect(weapon.campaign).to eq(new_campaign)
        end
      end
    end

    it "copies junctures with faction associations" do
      CampaignSeederService.seed_campaign(new_campaign)
      new_campaign.reload
      
      # Each juncture should have its faction association
      new_campaign.junctures.each do |juncture|
        expect(juncture.faction).to be_present
        expect(juncture.faction.campaign).to eq(new_campaign)
      end
    end

    it "creates unique names for duplicate characters" do
      CampaignSeederService.seed_campaign(new_campaign)
      new_campaign.reload
      
      # Character names should be unique within the campaign
      character_names = new_campaign.characters.pluck(:name)
      expect(character_names.uniq.count).to eq(character_names.count)
    end

    it "does not re-seed already seeded campaigns" do
      # First seeding
      CampaignSeederService.seed_campaign(new_campaign)
      original_count = new_campaign.reload.characters.count
      original_seeded_at = new_campaign.seeded_at
      
      # Attempt second seeding
      result = CampaignSeederService.seed_campaign(new_campaign)
      expect(result).to be false
      
      # Verify nothing changed
      new_campaign.reload
      expect(new_campaign.characters.count).to eq(original_count)
      expect(new_campaign.seeded_at).to be_within(1.second).of(original_seeded_at)
    end
  end

  describe "Seeding with background job" do
    it "enqueues CampaignSeederJob after campaign creation" do
      expect(CampaignSeederJob).to receive(:perform_later).with(kind_of(String))
      
      Campaign.create!(
        name: "Job Test Campaign #{Time.current.to_i}",
        user: gamemaster
      )
    end

    it "seeds campaign when job is executed" do
      campaign = Campaign.create!(
        name: "Job Execution Test #{Time.current.to_i}",
        user: gamemaster
      )
      
      expect(campaign.seeded_at).to be_nil
      
      # Execute job synchronously
      CampaignSeederJob.new.perform(campaign.id)
      
      campaign.reload
      expect(campaign.seeded_at).to be_present
      expect(campaign.characters.count).to eq(master_template.characters.where(is_template: true).count)
    end
  end
end