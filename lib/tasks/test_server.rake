namespace :test do
  desc "Clean database and start Rails server in test environment"
  task :server do
    puts "🧹 Cleaning test database..."
    
    # Set test environment
    ENV['RAILS_ENV'] = 'test'
    
    # Load Rails environment
    require_relative '../../config/environment'
    
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