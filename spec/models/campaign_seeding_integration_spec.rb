require 'rails_helper'

RSpec.describe "Campaign Seeding Integration", type: :model do
  let!(:gamemaster) do
    User.create!(
      email: 'gamemaster@example.com',
      first_name: 'Game',
      last_name: 'Master',
      password: 'TestPass123!',
      gamemaster: true
    )
  end
  
  let!(:master_template) do
    Campaign.create!(
      name: 'Master Template Campaign',
      is_master_template: true,
      user: gamemaster
    )
  end
  
  let!(:template_character) do
    Character.create!(
      name: 'Martial Artist Template',
      is_template: true,
      campaign: master_template,
      user: gamemaster
    )
  end
  
  let!(:template_weapon) do
    Weapon.create!(
      name: 'Template Weapon',
      damage: 8,
      campaign: master_template
    )
  end

  describe "Campaign creation and automatic seeding" do
    it "enqueues a seeding job after campaign creation" do
      expect(CampaignSeederJob).to receive(:perform_later).with(kind_of(String))
      
      Campaign.create!(name: 'New Campaign', user: gamemaster)
    end

    it "does not enqueue seeding job for master template campaigns" do
      expect(CampaignSeederJob).not_to receive(:perform_later)
      
      Campaign.create!(
        name: 'Another Master Template', 
        is_master_template: true, 
        user: gamemaster
      )
    end

    it "runs the complete seeding flow when job is executed" do
      # Create new campaign
      new_campaign = Campaign.create!(name: 'Test Campaign', user: gamemaster)
      expect(new_campaign.seeded_at).to be_nil
      expect(new_campaign.characters.count).to eq(0)
      expect(new_campaign.weapons.count).to eq(0)

      # Execute the seeding job synchronously
      CampaignSeederJob.new.perform(new_campaign.id)

      # Verify seeding completed
      new_campaign.reload
      expect(new_campaign.seeded_at).to be_present
      expect(new_campaign.characters.count).to eq(1)
      expect(new_campaign.weapons.count).to eq(1)
      
      # Verify content was copied correctly
      copied_character = new_campaign.characters.first
      expect(copied_character.name).to include('Martial Artist Template')
      expect(copied_character.campaign).to eq(new_campaign)
      expect(copied_character.user).to eq(gamemaster)
      
      copied_weapon = new_campaign.weapons.first
      expect(copied_weapon.name).to include('Template Weapon')
      expect(copied_weapon.campaign).to eq(new_campaign)
    end

    it "does not re-seed already seeded campaigns" do
      # Create and seed campaign
      new_campaign = Campaign.create!(name: 'Test Campaign', user: gamemaster)
      CampaignSeederJob.new.perform(new_campaign.id)
      
      original_seeded_at = new_campaign.reload.seeded_at
      original_character_count = new_campaign.characters.count
      
      # Try to seed again
      CampaignSeederJob.new.perform(new_campaign.id)
      
      new_campaign.reload
      expect(new_campaign.seeded_at).to be_within(1.second).of(original_seeded_at)
      expect(new_campaign.characters.count).to eq(original_character_count)
    end

    it "handles missing master template gracefully" do
      # Remove master template (destroy dependent records first)
      master_template.characters.destroy_all
      master_template.weapons.destroy_all
      master_template.destroy
      
      new_campaign = Campaign.create!(name: 'Test Campaign', user: gamemaster)
      
      # Should not raise error and should not mark as seeded
      expect {
        CampaignSeederJob.new.perform(new_campaign.id)
      }.not_to raise_error
      
      new_campaign.reload
      expect(new_campaign.seeded_at).to be_nil
      expect(new_campaign.characters.count).to eq(0)
    end
  end
end