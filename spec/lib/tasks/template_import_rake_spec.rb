require 'rails_helper'
require 'rake'

RSpec.describe 'template:import', type: :task do
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
    # Clear the rake task to allow it to be invoked multiple times
    Rake::Task['template:import'].reenable if Rake::Task.task_defined?('template:import')
    Rake::Task['template:export'].reenable if Rake::Task.task_defined?('template:export')
  end
  
  after(:each) do
    DatabaseCleaner.clean
  end

  describe 'rake template:import' do
    let!(:admin_user) do
      User.find_or_create_by!(email: "progressions@gmail.com") do |u|
        u.first_name = "Admin"
        u.last_name = "User"
        u.admin = true
        u.confirmed_at = Time.now
      end
    end
    
    context 'when no file path is provided' do
      it 'imports the most recent export file from db/exports' do
        # Create a master template
        Campaign.where(is_master_template: true).destroy_all
        master = Campaign.create!(
          name: 'Test Master Template',
          is_master_template: true,
          user: admin_user
        )
        
        Character.create!(
          campaign: master,
          name: 'Test Character',
          action_values: { 'Type' => 'PC' }
        )
        
        # Export it
        Rake::Task['template:export'].invoke
        
        # Clear the database
        Character.destroy_all
        Campaign.destroy_all
        
        # Import it back
        expect { Rake::Task['template:import'].invoke }.to output(/Template import completed successfully/).to_stdout
        
        # Verify it was imported
        imported = Campaign.find_by(is_master_template: true)
        expect(imported).to be_present
        expect(imported.name).to eq('Test Master Template')
        expect(imported.characters.count).to eq(1)
      end
    end
    
    context 'when a specific file path is provided' do
      it 'imports from the specified file' do
        # Create a simple SQL file
        sql_content = <<~SQL
          BEGIN;
          INSERT INTO campaigns (
            id, user_id, name, description, is_master_template, active,
            created_at, updated_at
          ) VALUES (
            '#{SecureRandom.uuid}',
            (SELECT id FROM users WHERE email = 'progressions@gmail.com' LIMIT 1),
            'Imported Template',
            NULL,
            true,
            true,
            NOW(),
            NOW()
          ) ON CONFLICT (id) DO NOTHING;
          COMMIT;
        SQL
        
        test_file = Rails.root.join('tmp', 'test_import.sql')
        File.write(test_file, sql_content)
        
        # Import it
        ENV['IMPORT_FILE'] = test_file.to_s
        expect { Rake::Task['template:import'].invoke }.to output(/Template import completed successfully/).to_stdout
        ENV.delete('IMPORT_FILE')
        
        # Verify
        imported = Campaign.find_by(name: 'Imported Template')
        expect(imported).to be_present
        expect(imported.is_master_template).to be true
        
        # Clean up
        File.delete(test_file) if File.exist?(test_file)
      end
    end
    
    context 'when the file does not exist' do
      it 'raises an error with helpful message' do
        ENV['IMPORT_FILE'] = '/nonexistent/file.sql'
        expect { Rake::Task['template:import'].invoke }.to raise_error(/Import file not found/)
        ENV.delete('IMPORT_FILE')
      end
    end
    
    context 'when no export files exist' do
      it 'raises an error with helpful message' do
        # Clear all export files
        export_dir = Rails.env.test? ? Rails.root.join('tmp', 'exports') : Rails.root.join('db', 'exports')
        Dir[export_dir.join('*.sql')].each { |f| File.delete(f) }

        expect { Rake::Task['template:import'].invoke }.to raise_error(/No export files found/)
      end
    end
    
    context 'idempotent imports' do
      it 'can be run multiple times without creating duplicates' do
        # Create and export a template
        Character.destroy_all
        Campaign.where(is_master_template: true).destroy_all
        master = Campaign.create!(
          name: 'Idempotent Test',
          is_master_template: true,
          user: admin_user
        )
        
        Rake::Task['template:export'].invoke
        
        # Import twice
        Rake::Task['template:import'].invoke
        Rake::Task['template:import'].reenable
        Rake::Task['template:import'].invoke
        
        # Should still only have one
        expect(Campaign.where(name: 'Idempotent Test').count).to eq(1)
      end
    end
    
    context 'with invalid SQL' do
      it 'rolls back the transaction on error' do
        # Create a SQL file with invalid syntax
        sql_content = <<~SQL
          BEGIN;
          INSERT INTO campaigns INVALID SYNTAX HERE;
          COMMIT;
        SQL
        
        test_file = Rails.root.join('tmp', 'invalid.sql')
        File.write(test_file, sql_content)
        
        initial_count = Campaign.count
        
        ENV['IMPORT_FILE'] = test_file.to_s
        expect { Rake::Task['template:import'].invoke }.to raise_error(ActiveRecord::StatementInvalid)
        ENV.delete('IMPORT_FILE')
        
        # No campaigns should have been created
        expect(Campaign.count).to eq(initial_count)
        
        # Clean up
        File.delete(test_file) if File.exist?(test_file)
      end
    end
  end
end