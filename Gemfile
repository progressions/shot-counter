source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

gem "psych"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.1"

gem "aws-sdk-s3", require: false
gem "active_model_serializers"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.4.2"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

gem "pdf-forms"

gem "httparty"

# Use Redis adapter to run Action Cable in production
gem "redis", "~> 4.0"

gem "sidekiq", "~> 7.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"
gem "devise", "~> 4.9.4"
gem "devise-jwt" , "~> 0.11.0"

gem 'notion-ruby-client'
gem "reverse_markdown"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Image processing gems - skip in test environment
unless ENV['SKIP_IMAGE_PROCESSING'] == 'true' || ENV['RAILS_ENV'] == 'test'
  gem "ruby-vips"
  gem "image_processing", "~> 1.2"
end
gem 'imagekitio'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem "rack-cors"

gem "discordrb", github: "shardlab/discordrb"

gem "kaminari"
gem "api-pagination"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "rspec-rails"
  gem "rspec_junit_formatter"  # For CircleCI test reporting
  gem "database_cleaner-active_record"
  gem "letter_opener"
  gem "pry-rails"
end

group :development do
  gem "bullet", group: :development
  gem "rack-mini-profiler", "~> 2.3"
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end


gem "dockerfile-rails", ">= 1.7", :group => :development
