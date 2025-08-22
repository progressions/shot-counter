namespace :test_db do
  desc "Reset test database and seed with test data"
  task reset: :environment do
    if Rails.env.test?
      puts "Resetting test database..."
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke  
      Rake::Task["db:migrate"].invoke
      Rake::Task["db:seed"].invoke
      puts "Test database reset complete!"
    else
      puts "ERROR: This task can only run in test environment"
      exit 1
    end
  end
end