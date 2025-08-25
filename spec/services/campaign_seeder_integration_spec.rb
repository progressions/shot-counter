require 'rails_helper'

RSpec.describe 'Campaign Seeding Integration', type: :integration do
  let!(:gamemaster) do
    User.create!(
      email: 'gm@example.com',
      first_name: 'Game',
      last_name: 'Master',
      password: 'TestPass123!',
      gamemaster: true
    )
  end
  
  let!(:player) do
    User.create!(
      email: 'player@example.com',
      first_name: 'Player',
      last_name: 'One',
      password: 'TestPass123!',
      gamemaster: false
    )
  end
  
  # Create Master Template Campaign with template characters
  let!(:master_template) do
    Campaign.create!(
      name: 'Master Template Campaign',
      is_master_template: true,
      user: gamemaster
    )
  end
  
  let!(:template_characters) do
    [
      Character.create!(
        name: 'Martial Artist Template',
        is_template: true,
        action_values: { "Type" => "PC", "Archetype" => "Martial Artist" },
        campaign: master_template,
        user: gamemaster
      ),
      Character.create!(
        name: 'Gunslinger Template',
        is_template: true,
        action_values: { "Type" => "PC", "Archetype" => "Gunslinger" },
        campaign: master_template,
        user: gamemaster
      )
    ]
  end
  
  # Create Master Campaign with non-template characters
  let!(:master_campaign) do
    Campaign.create!(
      name: 'Master Campaign',
      user: gamemaster
    )
  end
  
  let!(:master_characters) do
    [
      Character.create!(
        name: 'The Dragon Boss',
        is_template: false,
        action_values: { 
          "Type" => "Boss",
          "Martial Arts" => 15,
          "Defense" => 13,
          "Toughness" => 8
        },
        description: { "Background" => "Ancient martial arts master" },
        campaign: master_campaign,
        user: gamemaster
      ),
      Character.create!(
        name: 'Cyber Ninja',
        is_template: false,
        action_values: { 
          "Type" => "Featured Foe",
          "Martial Arts" => 12,
          "Scroungetech" => 10
        },
        campaign: master_campaign,
        user: gamemaster
      ),
      Character.create!(
        name: 'Street Thug',
        is_template: false,
        action_values: { "Type" => "Mook" },
        campaign: master_campaign,
        user: gamemaster
      ),
      Character.create!(
        name: 'Detective Lee',
        is_template: false,
        action_values: { "Type" => "Ally" },
        campaign: master_campaign,
        user: gamemaster
      )
    ]
  end
  
  # Add some template characters to Master Campaign that should NOT be copied
  let!(:master_campaign_templates) do
    Character.create!(
      name: 'Should Not Be Copied Template',
      is_template: true,
      action_values: { "Type" => "PC" },
      campaign: master_campaign,
      user: gamemaster
    )
  end
  
  describe 'Complete campaign creation and seeding flow' do
    context 'when creating a new campaign as gamemaster' do
      let(:new_campaign) do
        Campaign.create!(
          name: 'My New Campaign',
          user: gamemaster
        )
      end
      
      it 'seeds campaign with both template and Master Campaign characters' do
        expect {
          result = CampaignSeederService.seed_campaign(new_campaign)
          expect(result).to be true
        }.to change { new_campaign.characters.count }.from(0).to(6)
        # 2 templates from master_template + 4 non-templates from Master Campaign
        
        new_campaign.reload
        character_names = new_campaign.characters.pluck(:name)
        
        # Check template characters were copied
        expect(character_names).to include('Martial Artist Template')
        expect(character_names).to include('Gunslinger Template')
        
        # Check Master Campaign non-template characters were copied
        expect(character_names).to include('The Dragon Boss')
        expect(character_names).to include('Cyber Ninja')
        expect(character_names).to include('Street Thug')
        expect(character_names).to include('Detective Lee')
        
        # Check template from Master Campaign was NOT copied
        expect(character_names).not_to include('Should Not Be Copied Template')
      end
      
      it 'preserves character attributes when copying' do
        CampaignSeederService.seed_campaign(new_campaign)
        
        # Check Boss character attributes
        boss = new_campaign.characters.find_by(name: 'The Dragon Boss')
        expect(boss).not_to be_nil
        expect(boss.action_values["Type"]).to eq("Boss")
        expect(boss.action_values["Martial Arts"]).to eq(15)
        expect(boss.action_values["Defense"]).to eq(13)
        expect(boss.description["Background"]).to eq("Ancient martial arts master")
        
        # Check Featured Foe attributes
        ninja = new_campaign.characters.find_by(name: 'Cyber Ninja')
        expect(ninja.action_values["Type"]).to eq("Featured Foe")
        expect(ninja.action_values["Scroungetech"]).to eq(10)
      end
      
      it 'marks campaign as seeded after completion' do
        expect(new_campaign.seeded_at).to be_nil
        
        CampaignSeederService.seed_campaign(new_campaign)
        new_campaign.reload
        
        expect(new_campaign.seeded_at).to be_present
      end
      
      it 'does not reseed an already seeded campaign' do
        # First seeding
        CampaignSeederService.seed_campaign(new_campaign)
        first_count = new_campaign.characters.count
        first_seeded_at = new_campaign.reload.seeded_at
        
        # Attempt second seeding
        result = CampaignSeederService.seed_campaign(new_campaign)
        
        expect(result).to be false
        expect(new_campaign.characters.count).to eq(first_count)
        expect(new_campaign.reload.seeded_at).to eq(first_seeded_at)
      end
    end
    
    context 'when Master Campaign has many characters' do
      before do
        # Add 20 more characters to Master Campaign
        20.times do |i|
          Character.create!(
            name: "Enemy #{i}",
            is_template: false,
            action_values: { "Type" => "Featured Foe" },
            campaign: master_campaign,
            user: gamemaster
          )
        end
      end
      
      it 'copies all non-template characters efficiently' do
        new_campaign = Campaign.create!(name: 'Large Campaign', user: gamemaster)
        
        expect {
          CampaignSeederService.seed_campaign(new_campaign)
        }.to change { new_campaign.characters.count }.from(0).to(26)
        # 2 templates + 4 original + 20 additional = 26
      end
    end
    
    context 'when Master Campaign is empty' do
      before do
        master_characters.each(&:destroy)
        master_campaign_templates.destroy
      end
      
      it 'still seeds with template characters' do
        new_campaign = Campaign.create!(name: 'Campaign Without Master', user: gamemaster)
        
        expect {
          CampaignSeederService.seed_campaign(new_campaign)
        }.to change { new_campaign.characters.count }.from(0).to(2)
        # Only the 2 template characters
        
        character_names = new_campaign.characters.pluck(:name)
        expect(character_names).to include('Martial Artist Template')
        expect(character_names).to include('Gunslinger Template')
      end
    end
    
    context 'when Master Campaign does not exist' do
      before do
        master_characters.each(&:destroy)
        master_campaign_templates.destroy
        master_campaign.destroy
      end
      
      it 'still completes seeding with just templates' do
        new_campaign = Campaign.create!(name: 'Campaign No Master', user: gamemaster)
        
        result = CampaignSeederService.seed_campaign(new_campaign)
        expect(result).to be true
        
        expect(new_campaign.characters.count).to eq(2)
        expect(new_campaign.reload.seeded_at).to be_present
      end
    end
    
    context 'when neither Master Template nor Master Campaign exist' do
      before do
        template_characters.each(&:destroy)
        master_template.destroy
        master_characters.each(&:destroy)
        master_campaign_templates.destroy
        master_campaign.destroy
      end
      
      it 'returns false and does not mark as seeded' do
        new_campaign = Campaign.create!(name: 'Campaign No Seeds', user: gamemaster)
        
        result = CampaignSeederService.seed_campaign(new_campaign)
        expect(result).to be false
        
        expect(new_campaign.characters.count).to eq(0)
        expect(new_campaign.reload.seeded_at).to be_nil
      end
    end
  end
  
  describe 'Character ownership and associations' do
    let(:new_campaign) do
      Campaign.create!(name: 'Association Test Campaign', user: gamemaster)
    end
    
    it 'sets correct user ownership for all copied characters' do
      CampaignSeederService.seed_campaign(new_campaign)
      
      new_campaign.characters.each do |character|
        expect(character.user).to eq(gamemaster)
        expect(character.campaign).to eq(new_campaign)
      end
    end
  end
end