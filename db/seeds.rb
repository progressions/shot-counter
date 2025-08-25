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
  password: 'TestPass123!',
  password_confirmation: 'TestPass123!',
  first_name: 'Isaac',
  last_name: 'Priestley',
  gamemaster: true,
  admin: true,  # Required for API v2 users endpoint access
  confirmed_at: Time.current  # Confirm email for test user
)
test_user.save!

# Player user
player_user = User.find_or_create_by!(email: 'player@example.com') do |user|
  user.password = 'TestPass123!'
  user.password_confirmation = 'TestPass123!'
  user.first_name = 'Player'
  user.last_name = 'Test'
  user.gamemaster = false
  user.confirmed_at = Time.current  # Confirm email for test user
end

puts "Created gamemaster: #{test_user.email}, ID: #{test_user.id}"
puts "Gamemaster password valid: #{test_user.valid_password?('TestPass123!')}"
puts "Created player: #{player_user.email}, ID: #{player_user.id}"
puts "Player password valid: #{player_user.valid_password?('TestPass123!')}"

# Create master template campaign for seeding new campaigns
master_template = Campaign.find_or_create_by(
  name: 'Master Template Campaign',
  is_master_template: true
) do |campaign|
  campaign.user = test_user
  campaign.description = 'Master template containing schticks, weapons, and character templates for seeding new campaigns'
end

puts "Created master template campaign: #{master_template.name}, ID: #{master_template.id}"

# Populate Master Template Campaign with starter content
# Create schticks for the master template
master_schticks = [
  { name: 'Both Guns Blazing', category: 'Guns', path: 'Way of the Gun', description: 'Fire two guns at once' },
  { name: 'Lightning Reload', category: 'Guns', path: 'Way of the Gun', description: 'Reload instantly' },
  { name: 'Path of the Righteous Fist', category: 'Martial Arts', path: 'Path of the Righteous Fist', description: 'Martial arts mastery' },
  { name: 'Drunken Master', category: 'Martial Arts', path: 'Path of the Drunken Master', description: 'Fight better when drunk' },
  { name: 'Blast', category: 'Sorcery', path: 'Sorcery', description: 'Magical energy attack' },
  { name: 'Divination', category: 'Sorcery', path: 'Sorcery', description: 'See the future' }
]

master_schticks.each do |s|
  master_template.schticks.find_or_create_by(name: s[:name]) do |schtick|
    schtick.category = s[:category]
    schtick.path = s[:path]
    schtick.description = s[:description]
  end
end

# Create weapons for the master template
master_weapons = [
  { name: 'Beretta M9', damage: '10/2/5', concealment: '2', reload_value: '1' },
  { name: 'AK-47', damage: '13/5/3', concealment: '5', reload_value: '1' },
  { name: 'Sword', damage: '12', concealment: '4', reload_value: '0' },
  { name: 'Staff', damage: '10', concealment: '5', reload_value: '0' },
  { name: 'Throwing Stars', damage: '7', concealment: '1', reload_value: '0' }
]

master_weapons.each do |w|
  master_template.weapons.find_or_create_by(name: w[:name]) do |weapon|
    weapon.damage = w[:damage]
    weapon.concealment = w[:concealment]
    weapon.reload_value = w[:reload_value]
  end
end

# Create factions for the master template
master_factions = [
  { name: 'Dragons', description: 'Heroes fighting for justice' },
  { name: 'Eaters of the Lotus', description: 'Evil sorcerers from ancient China' },
  { name: 'Ascended', description: 'Animal spirits controlling the modern world' },
  { name: 'Jammers', description: 'Anarchists from the future' }
]

master_factions.each do |f|
  master_template.factions.find_or_create_by(name: f[:name]) do |faction|
    faction.description = f[:description]
  end
end

# Create junctures for the master template (with faction associations)
master_junctures = [
  { name: 'Ancient', description: '69 AD - The height of Imperial China', faction_name: 'Eaters of the Lotus' },
  { name: '1850s', description: '1850 - The opium wars and colonial era', faction_name: 'Ascended' },
  { name: 'Contemporary', description: '2020 - The modern world', faction_name: 'Dragons' },
  { name: 'Future', description: '2074 - The dystopian future', faction_name: 'Jammers' }
]

master_junctures.each do |j|
  faction = master_template.factions.find_by(name: j[:faction_name])
  master_template.junctures.find_or_create_by(name: j[:name]) do |juncture|
    juncture.description = j[:description]
    juncture.faction = faction
  end
end

puts "   Master Template populated with:"
puts "     - Schticks: #{master_template.schticks.count}"
puts "     - Weapons: #{master_template.weapons.count}"
puts "     - Factions: #{master_template.factions.count}"
puts "     - Junctures: #{master_template.junctures.count}"

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

# Add template characters to both test campaign and master template campaign
[test_campaign, master_template].each do |campaign|
  template_characters.each do |template_data|
    Character.find_or_create_by(
      name: template_data[:name],
      is_template: true,
      campaign: campaign
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
end

# Now associate schticks and weapons with Master Template characters
master_template.reload # Reload to get the newly created characters
master_template.characters.where(is_template: true).each do |character|
  # Add 2 random schticks if none exist
  if character.schticks.empty? && master_template.schticks.any?
    character.schticks << master_template.schticks.sample(2)
  end
  
  # Add 2 random weapons if none exist
  if character.weapons.empty? && master_template.weapons.any?
    character.weapons << master_template.weapons.sample(2)
  end
end

puts "   Template characters updated with schticks and weapons"

# Create a test party with characters
test_party = Party.find_or_create_by(
  name: 'The Heroes',
  campaign: test_campaign
) do |party|
  party.description = 'A band of brave heroes ready for adventure'
end

# Create party-specific characters if they don't exist
party_characters = [
  {
    name: 'Captain Strongarm',
    character_type: 'PC',
    archetype: 'Martial Artist'
  },
  {
    name: 'Shadow Ninja',
    character_type: 'PC',
    archetype: 'Killer'
  },
  {
    name: 'Lucky Luke',
    character_type: 'PC',
    archetype: 'Bandit'
  },
  {
    name: 'Doctor Wisdom',
    character_type: 'Ally',
    archetype: 'Everyday Hero'
  }
]

party_characters.each do |char_data|
  character = Character.find_or_create_by(
    name: char_data[:name],
    campaign: test_campaign
  ) do |c|
    c.action_values = Character::DEFAULT_ACTION_VALUES.merge({
      "Type" => char_data[:character_type],
      "Archetype" => char_data[:archetype]
    })
  end
  
  # Add character to party if not already a member
  unless test_party.characters.include?(character)
    Membership.find_or_create_by(
      party: test_party,
      character: character
    )
  end
end

# Create a test vehicle for the party
test_vehicle = Vehicle.find_or_create_by(
  name: 'The Hero Mobile',
  campaign: test_campaign
) do |vehicle|
  vehicle.action_values = {
    "Acceleration" => 8,
    "Handling" => 10,
    "Squeal" => 11,
    "Frame" => 7,
    "Crunch" => 10,
    "Condition Points" => 30,
    "Chase Points" => 0
  }
end

# Add vehicle to party if not already a member
unless test_party.vehicles.include?(test_vehicle)
  Membership.find_or_create_by(
    party: test_party,
    vehicle: test_vehicle
  )
end

# Create a test fight for party-to-fight testing
test_fight = Fight.find_or_create_by(
  name: 'Test Fight for Party Addition',
  campaign: test_campaign
) do |fight|
  fight.description = 'A test fight for validating the party-to-fight feature'
  fight.season = 1
  fight.session = 1
end

puts "✅ Seed data created:"
puts "   Gamemaster: #{test_user.email}"
puts "   Player: #{player_user.email}"
puts "   Campaigns: #{created_campaigns.map(&:name).join(', ')}"
puts "   Current Campaign: #{test_campaign.name}"
puts "   Characters: #{test_campaign.characters.count}"
puts "   Template Characters: #{Character.where(is_template: true).count}"
puts "   Party: #{test_party.name} with #{test_party.characters.count} characters and #{test_party.vehicles.count} vehicles"
puts "   Test Fight: #{test_fight.name}"
