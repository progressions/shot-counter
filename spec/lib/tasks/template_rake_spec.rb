require 'rails_helper'
require 'rake'

RSpec.describe 'template:export', type: :task do
  # Use truncation strategy for rake task tests since they run in separate database connections
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
    # Clean up any existing export files - use shell glob to remove all SQL files
    Dir[Rails.root.join('db', 'exports', '*.sql')].each { |f| File.delete(f) }
    # Clear the rake task to allow it to be invoked multiple times
    Rake::Task['template:export'].reenable if Rake::Task.task_defined?('template:export')
  end
  
  after(:each) do
    DatabaseCleaner.clean
  end

  describe 'rake template:export' do
    let!(:user) { User.create!(email: "gamemaster@example.com", first_name: "Game", last_name: "Master", confirmed_at: Time.now) }
    
    let(:master_template) do
      Campaign.create!(
        name: 'Master Template Campaign',
        is_master_template: true,
        user: user
      )
    end

    let(:regular_campaign) do
      Campaign.create!(
        name: 'Regular Campaign',
        is_master_template: false,
        user: user
      )
    end

    context 'when master template exists' do
      before do
        # Ensure no other master templates exist
        Campaign.where(is_master_template: true).destroy_all
        master_template
        # Create associated data - use instance variables consistently
        @character = Character.create!(
          campaign_id: master_template.id, 
          name: 'Template Character', 
          action_values: { 'Type' => 'Featured Foe' }
        )
        @vehicle = Vehicle.create!(
          campaign_id: master_template.id, 
          name: 'Template Vehicle'
        )
        @faction = Faction.create!(
          campaign_id: master_template.id, 
          name: 'Template Faction'
        )
        @juncture = Juncture.create!(
          campaign_id: master_template.id, 
          faction_id: @faction.id, 
          name: 'Contemporary'
        )
        @schtick = Schtick.create!(
          campaign_id: master_template.id, 
          name: 'Test Schtick', 
          category: 'Guns'
        )
        @weapon = Weapon.create!(
          campaign_id: master_template.id, 
          name: 'Test Weapon', 
          damage: 7
        )
        
        # Create join table associations
        @character.schticks << @schtick
        @character.weapons << @weapon
        @character.update!(faction_id: @faction.id)
        
        # Ensure data is committed and visible
        master_template.reload
      end

      it 'creates an export file in db/exports directory' do
        # Get initial files before running the export
        initial_files = Dir[Rails.root.join('db', 'exports', '*.sql')].to_set
        
        Rake::Task['template:export'].invoke
        
        # Get files after export
        final_files = Dir[Rails.root.join('db', 'exports', '*.sql')].to_set
        
        # Find new files created by this test
        new_files = final_files - initial_files
        
        # Should have exactly one new file
        expect(new_files.size).to eq(1)
        
        # Verify the new file was just created and has expected content
        new_file = new_files.first
        expect(File.exist?(new_file)).to be true
        expect(File.mtime(new_file)).to be > 5.seconds.ago
        
        # Verify it contains template data
        content = File.read(new_file)
        expect(content).to include('Master Template Campaign')
      end

      it 'includes the master template campaign in the export' do
        Rake::Task['template:export'].invoke
        
        export_files = Dir[Rails.root.join('db', 'exports', '*.sql')].sort
        export_file = export_files.last
        content = File.read(export_file)
        
        expect(content).to include('Master Template Campaign')
        expect(content).to include('is_master_template')
        expect(content).to include('INSERT INTO campaigns')
      end

      it 'includes associated characters' do
        # Verify the data exists before export
        expect(master_template.reload.characters.count).to eq(1)
        expect(master_template.characters.first.name).to eq('Template Character')
        
        # Debug: Check what campaign the exporter will find
        found_campaign = Campaign.find_by(is_master_template: true)
        expect(found_campaign).to eq(master_template)
        expect(found_campaign.characters.count).to eq(1)
        
        Rake::Task['template:export'].invoke
        
        # Get the most recent export file
        export_files = Dir[Rails.root.join('db', 'exports', '*.sql')].sort
        export_file = export_files.last
        content = File.read(export_file)
        
        expect(content).to include('Template Character')
        expect(content).to include('INSERT INTO characters')
        # Note: image_url is computed from Active Storage attachments, not a simple DB field
      end

      it 'includes join table associations' do
        Rake::Task['template:export'].invoke
        
        # Get the most recent export file
        export_files = Dir[Rails.root.join('db', 'exports', '*.sql')].sort
        export_file = export_files.last
        content = File.read(export_file)
        
        # Check for character_schticks
        expect(content).to include('character_schticks')
        expect(content).to include('INSERT INTO character_schticks')
        
        # Check for carries (character-weapon)
        expect(content).to include('carries')
        expect(content).to include('INSERT INTO carries')
        
        # Check that factions are exported
        expect(content).to include('Template Faction')
        expect(content).to include('INSERT INTO factions')
      end

      it 'includes image positions when they exist' do
        # Create an image position for the character
        ImagePosition.create!(
          positionable: @character,
          context: 'desktop_entity',
          x_position: 0.5,
          y_position: 0.3,
          style_overrides: { 'scale' => 1.2 }
        )
        
        Rake::Task['template:export'].invoke
        
        # Get the most recent export file
        export_files = Dir[Rails.root.join('db', 'exports', '*.sql')].sort
        export_file = export_files.last
        content = File.read(export_file)
        
        # Check for image_positions
        expect(content).to include('INSERT INTO image_positions')
        expect(content).to include('Character')
        expect(content).to include('0.5')
        expect(content).to include('0.3')
      end

      it 'wraps all statements in a transaction' do
        Rake::Task['template:export'].invoke
        
        export_files = Dir[Rails.root.join('db', 'exports', '*.sql')].sort
        export_file = export_files.last
        content = File.read(export_file)
        
        expect(content).to start_with('BEGIN;')
        expect(content).to end_with("COMMIT;\n")
      end

      it 'uses ON CONFLICT DO NOTHING for idempotent imports' do
        Rake::Task['template:export'].invoke
        
        export_files = Dir[Rails.root.join('db', 'exports', '*.sql')].sort
        export_file = export_files.last
        content = File.read(export_file)
        
        expect(content).to include('ON CONFLICT (id) DO NOTHING')
      end

      it 'creates file with timestamp in filename' do
        # Get initial files before running export
        initial_files = Dir[Rails.root.join('db', 'exports', 'master_template_export_*.sql')].to_set
        
        Rake::Task['template:export'].invoke
        
        # Get files after export
        final_files = Dir[Rails.root.join('db', 'exports', 'master_template_export_*.sql')].to_set
        
        # Find new files created by this test
        new_files = final_files - initial_files
        
        # Should have exactly one new file
        expect(new_files.size).to eq(1)
        
        # Verify filename format
        filename = File.basename(new_files.first)
        expect(filename).to match(/master_template_export_\d{8}_\d{6}\.sql/)
      end

      it 'exports in correct dependency order' do
        Rake::Task['template:export'].invoke
        
        export_files = Dir[Rails.root.join('db', 'exports', '*.sql')].sort
        export_file = export_files.last
        content = File.read(export_file)
        
        # Ensure campaigns come before characters
        campaign_pos = content.index('INSERT INTO campaigns')
        character_pos = content.index('INSERT INTO characters')
        faction_pos = content.index('INSERT INTO factions')
        juncture_pos = content.index('INSERT INTO junctures')
        
        expect(campaign_pos).to be < character_pos
        expect(faction_pos).to be < juncture_pos # junctures reference factions
      end

      it 'excludes regular campaigns' do
        regular_campaign
        Character.create!(campaign: regular_campaign, name: 'Regular Character', action_values: { 'Type' => 'Featured Foe' })
        
        Rake::Task['template:export'].invoke
        
        export_files = Dir[Rails.root.join('db', 'exports', '*.sql')].sort
        export_file = export_files.last
        content = File.read(export_file)
        
        expect(content).not_to include(regular_campaign.id)
        expect(content).not_to include('Regular Character')
      end
    end

    context 'when no master template exists' do
      it 'raises an error with helpful message' do
        expect {
          Rake::Task['template:export'].invoke
        }.to raise_error(RuntimeError, /No master template campaign found/)
      end
    end

    context 'when db/exports directory does not exist' do
      before do
        FileUtils.rm_rf(Rails.root.join('db', 'exports'))
        master_template
      end

      it 'creates the directory automatically' do
        expect(Dir.exist?(Rails.root.join('db', 'exports'))).to be false
        
        Rake::Task['template:export'].invoke
        
        expect(Dir.exist?(Rails.root.join('db', 'exports'))).to be true
      end
    end

    context 'logging' do
      before { master_template }

      it 'logs export progress to Rails logger' do
        expect(Rails.logger).to receive(:info).with(/Starting master template export/).at_least(:once)
        expect(Rails.logger).to receive(:info).with(/Exporting campaign:/).at_least(:once)
        expect(Rails.logger).to receive(:info).with(/Export completed:/).at_least(:once)
        # Allow any other info calls
        allow(Rails.logger).to receive(:info)
        
        Rake::Task['template:export'].invoke
      end
    end
  end
end