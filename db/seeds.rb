# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# SAFEGUARD: Prevent accidental seeding in development with existing data
if Rails.env.development?
  puts "🚨 DEVELOPMENT ENVIRONMENT DETECTED"
  puts "Database: #{ActiveRecord::Base.connection.current_database}"
  
  # Check if development database already has users (indicating it's not a fresh setup)
  if User.exists?
    existing_user_count = User.count
    existing_campaign_count = Campaign.count
    
    puts "⚠️  WARNING: Development database contains existing data:"
    puts "   - Users: #{existing_user_count}"
    puts "   - Campaigns: #{existing_campaign_count}"
    puts ""
    puts "🛡️  SAFETY CHECK: Seeding will only ADD test data, not destroy existing data."
    puts "   This seed file uses find_or_create_by which is safe for existing data."
    puts ""
    print "Continue seeding development database? (y/N): "
    
    response = STDIN.gets.chomp.downcase
    unless response == 'y' || response == 'yes'
      puts "❌ Seeding cancelled by user"
      exit 0
    end
    
    puts "✅ User confirmed - proceeding with safe seeding..."
  else
    puts "✅ Fresh development database detected - proceeding with seeding..."
  end
end

puts "🌱 Seeding database in #{Rails.env} environment..."
puts "📍 Database: #{ActiveRecord::Base.connection.current_database}"

# Create test users for automation (using known working credentials)
# Gamemaster user
test_user = User.find_or_initialize_by(email: 'progressions@gmail.com')
test_user.assign_attributes(
  password: 'password',
  password_confirmation: 'password',
  first_name: 'Isaac',
  last_name: 'Priestley',
  gamemaster: true,
  admin: true,  # Required for API v2 users endpoint access
  confirmed_at: Time.current  # Confirm email for test user
)
test_user.save!

# Player user
player_user = User.find_or_create_by!(email: 'player@example.com') do |user|
  user.password = 'password'
  user.password_confirmation = 'password'
  user.first_name = 'Player'
  user.last_name = 'Test'
  user.gamemaster = false
  user.confirmed_at = Time.current  # Confirm email for test user
end

puts "Created gamemaster: #{test_user.email}, ID: #{test_user.id}"
puts "Gamemaster password valid: #{test_user.valid_password?('password')}"
puts "Created player: #{player_user.email}, ID: #{player_user.id}"
puts "Player password valid: #{player_user.valid_password?('password')}"

# Create multiple test campaigns for activation testing
test_campaigns = [
  {
    name: 'Test Campaign',
    description: 'Primary campaign for automated testing'
  },
  {
    name: 'Secondary Campaign',
    description: 'Second campaign for testing activation functionality'
  },
  {
    name: 'Third Campaign',
    description: 'Third campaign for testing multiple activation switches'
  }
]

created_campaigns = test_campaigns.map do |campaign_data|
  campaign = Campaign.find_or_create_by(name: campaign_data[:name]) do |c|
    c.user = test_user  # Gamemaster owns the campaign
    c.description = campaign_data[:description]
  end
  
  # Add both users to the campaign if not already added
  [test_user, player_user].each do |user|
    unless campaign.users.include?(user)
      campaign.users << user
    end
  end
  
  campaign
end

# Set the first campaign as the current campaign for both users
test_campaign = created_campaigns.first
test_user.update!(current_campaign_id: test_campaign.id)
player_user.update!(current_campaign_id: test_campaign.id)

# Create some test characters for adding to fights
test_characters = [
  {
    name: 'Fred the Bounty Hunter',
    character_type: 'Ally',
    archetype: 'Bandit'
  },
  {
    name: 'Test Hero',
    character_type: 'PC',
    archetype: 'Martial Artist'
  },
  {
    name: 'Test Villain',
    character_type: 'Boss',
    archetype: 'Big Boss'
  }
]

test_characters.each do |char_data|
  Character.find_or_create_by(
    name: char_data[:name],
    campaign: test_campaign
  ) do |character|
    character.action_values = Character::DEFAULT_ACTION_VALUES.merge({
      "Type" => char_data[:character_type],
      "Archetype" => char_data[:archetype]
    })
  end
end

# Create template characters for character creation (only PC types need is_template)
template_characters = [
  {
    name: 'Bandit',
    archetype: 'Bandit',
    description: 'A common criminal archetype for creating new characters.',
    type: 'PC'
  },
  {
    name: 'Everyday Hero',
    archetype: 'Everyday Hero', 
    description: 'An ordinary person thrust into extraordinary circumstances.',
    type: 'PC'
  },
  {
    name: 'Killer',
    archetype: 'Killer',
    description: 'A professional assassin or dangerous combatant.',
    type: 'PC'
  },
  {
    name: 'Martial Artist',
    archetype: 'Martial Artist',
    description: 'A warrior trained in ancient fighting techniques.',
    type: 'PC'
  }
]

template_characters.each do |template_data|
  Character.find_or_create_by(
    name: template_data[:name],
    is_template: true,
    campaign: test_campaign
  ) do |character|
    character.action_values = Character::DEFAULT_ACTION_VALUES.merge({
      "Archetype" => template_data[:archetype],
      "Type" => template_data[:type]
    })
    # Description should be a Hash with specific keys
    character.description = {
      "Backstory" => template_data[:description],
      "Nicknames" => "",
      "Age" => "",
      "Height" => ""
    }
  end
end

puts "✅ Seed data created:"
puts "   Gamemaster: #{test_user.email}"
puts "   Player: #{player_user.email}"
puts "   Campaigns: #{created_campaigns.map(&:name).join(', ')}"
puts "   Current Campaign: #{test_campaign.name}"
puts "   Characters: #{test_campaign.characters.count}"
puts "   Template Characters: #{Character.where(is_template: true).count}"
