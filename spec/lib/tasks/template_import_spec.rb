require 'rails_helper'
require 'rake'

RSpec.describe 'template:export import validation', type: :task do
  # Use truncation strategy for database operations
  self.use_transactional_tests = false
  
  before(:all) do
    Rails.application.load_tasks
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  before(:each) do
    DatabaseCleaner.start
    # Clean up any existing export files
    Dir[Rails.root.join('db', 'exports', '*.sql')].each { |f| File.delete(f) }
    # Clear the rake task to allow it to be invoked multiple times
    Rake::Task['template:export'].reenable if Rake::Task.task_defined?('template:export')
  end
  
  after(:each) do
    DatabaseCleaner.clean
  end

  describe 'exported SQL can be imported' do
    let!(:user) do
      User.find_or_create_by!(email: "gamemaster@example.com") do |u|
        u.first_name = "Game"
        u.last_name = "Master"
        u.confirmed_at = Time.now
      end
    end
    
    let(:master_template) do
      Campaign.create!(
        name: 'Master Template Campaign',
        is_master_template: true,
        user: user
      )
    end

    it 'generates valid SQL that can be imported without errors' do
      # Setup test data
      Campaign.where(is_master_template: true).destroy_all
      master_template
      
      # Create test entities
      faction = Faction.create!(
        campaign_id: master_template.id,
        name: 'Test Faction'
      )
      
      character = Character.create!(
        campaign_id: master_template.id,
        name: 'Test Character',
        action_values: { 'Type' => 'PC' },
        faction_id: faction.id
      )
      
      schtick = Schtick.create!(
        campaign_id: master_template.id,
        name: 'Test Schtick',
        category: 'Guns'
      )
      
      weapon = Weapon.create!(
        campaign_id: master_template.id,
        name: 'Test Weapon',
        damage: 10
      )
      
      character.schticks << schtick
      character.weapons << weapon
      
      # Export the data
      Rake::Task['template:export'].invoke
      
      # Get the exported SQL file
      export_files = Dir[Rails.root.join('db', 'exports', '*.sql')].sort
      export_file = export_files.last
      expect(export_file).to be_present
      
      sql_content = File.read(export_file)
      
      # Clear the database (except users)
      CharacterSchtick.delete_all
      Carry.delete_all
      Character.delete_all
      Schtick.delete_all
      Weapon.delete_all
      Faction.delete_all
      Campaign.delete_all
      
      # Ensure a user exists for the import
      User.create!(email: 'progressions@gmail.com', first_name: 'Admin', last_name: 'User', admin: true, confirmed_at: Time.now) unless User.exists?(email: 'progressions@gmail.com')
      
      # Import the SQL
      ActiveRecord::Base.connection.execute(sql_content)
      # Reset connection state after executing raw SQL with transactions
      ActiveRecord::Base.connection.reconnect!
      
      # Verify data was imported correctly
      imported_campaign = Campaign.find_by(is_master_template: true)
      expect(imported_campaign).to be_present
      expect(imported_campaign.name).to eq('Master Template Campaign')
      
      expect(imported_campaign.factions.count).to eq(1)
      expect(imported_campaign.characters.count).to eq(1)
      expect(imported_campaign.schticks.count).to eq(1)
      expect(imported_campaign.weapons.count).to eq(1)
      
      imported_character = imported_campaign.characters.first
      expect(imported_character.name).to eq('Test Character')
      expect(imported_character.faction_id).to eq(faction.id)
      expect(imported_character.schticks.count).to eq(1)
      expect(imported_character.weapons.count).to eq(1)
    end

    it 'supports idempotent imports (can be run multiple times)' do
      # Setup test data - clear in correct order to avoid FK violations
      CharacterSchtick.destroy_all
      Carry.destroy_all
      Character.destroy_all
      Schtick.destroy_all
      Weapon.destroy_all
      Faction.destroy_all
      Campaign.where(is_master_template: true).destroy_all
      master_template
      
      character = Character.create!(
        campaign_id: master_template.id,
        name: 'Test Character',
        action_values: { 'Type' => 'PC' }
      )
      
      # Export the data
      Rake::Task['template:export'].invoke
      
      # Get the exported SQL file
      export_files = Dir[Rails.root.join('db', 'exports', '*.sql')].sort
      export_file = export_files.last
      sql_content = File.read(export_file)
      
      # Ensure a user exists for the import
      User.create!(email: 'progressions@gmail.com', first_name: 'Admin', last_name: 'User', admin: true, confirmed_at: Time.now) unless User.exists?(email: 'progressions@gmail.com')
      
      # Import the SQL twice
      ActiveRecord::Base.connection.execute(sql_content)
      ActiveRecord::Base.connection.reconnect!
      ActiveRecord::Base.connection.execute(sql_content)
      ActiveRecord::Base.connection.reconnect!
      
      # Verify no duplicates were created
      expect(Campaign.where(is_master_template: true).count).to eq(1)
      expect(Character.where(name: 'Test Character').count).to eq(1)
    end

    it 'preserves UUIDs for all entities' do
      # Setup test data - clear in correct order
      CharacterSchtick.destroy_all
      Carry.destroy_all
      Character.destroy_all
      Schtick.destroy_all
      Weapon.destroy_all
      Faction.destroy_all
      Campaign.where(is_master_template: true).destroy_all
      master_template
      
      original_campaign_id = master_template.id
      
      character = Character.create!(
        campaign_id: master_template.id,
        name: 'Test Character',
        action_values: { 'Type' => 'PC' }
      )
      original_character_id = character.id
      
      faction = Faction.create!(
        campaign_id: master_template.id,
        name: 'Test Faction'
      )
      original_faction_id = faction.id
      
      # Export the data
      Rake::Task['template:export'].invoke
      
      # Get the exported SQL file
      export_files = Dir[Rails.root.join('db', 'exports', '*.sql')].sort
      export_file = export_files.last
      sql_content = File.read(export_file)
      
      # Clear the database (except users)
      Character.delete_all
      Faction.delete_all
      Campaign.delete_all
      
      # Ensure a user exists for the import
      User.create!(email: 'progressions@gmail.com', first_name: 'Admin', last_name: 'User', admin: true, confirmed_at: Time.now) unless User.exists?(email: 'progressions@gmail.com')
      
      # Import the SQL
      ActiveRecord::Base.connection.execute(sql_content)
      # Reset connection state after executing raw SQL with transactions
      ActiveRecord::Base.connection.reconnect!
      
      # Verify UUIDs were preserved
      expect(Campaign.find_by(id: original_campaign_id)).to be_present
      expect(Character.find_by(id: original_character_id)).to be_present
      expect(Faction.find_by(id: original_faction_id)).to be_present
    end

    it 'handles special characters in text fields' do
      # Setup test data - clear in correct order to avoid FK violations
      CharacterSchtick.destroy_all
      Carry.destroy_all
      Character.destroy_all
      Schtick.destroy_all
      Weapon.destroy_all
      Faction.destroy_all
      Campaign.where(is_master_template: true).destroy_all
      master_template
      
      character = Character.create!(
        campaign_id: master_template.id,
        name: "Test's \"Special\" Character",
        description: {
          "Background" => "He's from O'Malley's pub",
          "Notes" => "Uses \"quotes\" and 'apostrophes'"
        },
        action_values: { 'Type' => 'PC' }
      )
      
      # Export the data
      Rake::Task['template:export'].invoke
      
      # Get the exported SQL file
      export_files = Dir[Rails.root.join('db', 'exports', '*.sql')].sort
      export_file = export_files.last
      sql_content = File.read(export_file)
      
      # Clear the database (except users)
      Character.delete_all
      Campaign.delete_all
      
      # Ensure a user exists for the import
      User.create!(email: 'progressions@gmail.com', first_name: 'Admin', last_name: 'User', admin: true, confirmed_at: Time.now) unless User.exists?(email: 'progressions@gmail.com')
      
      # Import the SQL
      ActiveRecord::Base.connection.execute(sql_content)
      # Reset connection state after executing raw SQL with transactions
      ActiveRecord::Base.connection.reconnect!
      
      # Verify special characters were preserved
      imported_character = Character.find_by(id: character.id)
      expect(imported_character.name).to eq("Test's \"Special\" Character")
      expect(imported_character.description["Background"]).to eq("He's from O'Malley's pub")
      expect(imported_character.description["Notes"]).to eq("Uses \"quotes\" and 'apostrophes'")
    end
  end
end