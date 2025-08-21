namespace :test do
  desc "Clean database and start Rails server in test environment"
  task :server do
    # SAFETY CHECK: Ensure we're in test environment
    unless ENV['RAILS_ENV'] == 'test' || Rails.env.test?
      puts "🚨 SAFETY ERROR: This task can only run in test environment!"
      puts "   Current environment: #{Rails.env}"
      puts "   Current ENV['RAILS_ENV']: #{ENV['RAILS_ENV']}"
      puts ""
      puts "💡 To run this safely:"
      puts "   RAILS_ENV=test rails test:server"
      exit 1
    end
    
    puts "🧹 Cleaning test database..."
    puts "📍 Environment: #{Rails.env}"
    
    # Set test environment explicitly
    ENV['RAILS_ENV'] = 'test'
    
    # Load Rails environment
    require_relative '../../config/environment'
    
    # Double-check we're connected to test database
    db_name = ActiveRecord::Base.connection.current_database
    unless db_name.include?('test')
      puts "🚨 SAFETY ERROR: Not connected to test database!"
      puts "   Current database: #{db_name}"
      puts "   This task should only clean test databases"
      exit 1
    end
    
    puts "✅ Confirmed test database: #{db_name}"
    
    # Clean database using DatabaseCleaner
    require 'database_cleaner/active_record'
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
    
    puts "✅ Database cleaned"
    puts "🌱 Running database seed..."
    
    # Run seeds
    Rails.application.load_seed
    
    puts "✅ Database seeded"
    puts "🚀 Starting Rails server in test environment on port 3004..."
    
    # Start the server
    exec "rails server -p 3004"
  end
end