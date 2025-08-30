#!/usr/bin/env ruby

# Script to check master template status in production

puts "Checking for master template campaign..."
puts "=" * 50

master = Campaign.find_by(is_master_template: true)

if master
  puts "✅ Master template found!"
  puts "  Name: #{master.name}"
  puts "  ID: #{master.id}"
  puts "  Created: #{master.created_at}"
  puts "  Schticks: #{master.schticks.count}"
  puts "  Weapons: #{master.weapons.count}"
  puts "  Characters: #{master.characters.count}"
  puts "  Vehicles: #{master.vehicles.count}"
  puts "  Factions: #{master.factions.count}"
  puts "  Junctures: #{master.junctures.count}"
else
  puts "❌ No master template found!"
  puts ""
  puts "Checking if there's a campaign named 'Master Campaign'..."
  master_by_name = Campaign.find_by(name: "Master Campaign")
  
  if master_by_name
    puts "Found campaign named 'Master Campaign':"
    puts "  ID: #{master_by_name.id}"
    puts "  is_master_template: #{master_by_name.is_master_template}"
    puts ""
    puts "To fix this, run:"
    puts "  Campaign.find(#{master_by_name.id}).update!(is_master_template: true)"
  else
    puts "No campaign named 'Master Campaign' found either."
    puts ""
    puts "Available campaigns:"
    Campaign.limit(10).each do |c|
      puts "  - #{c.name} (ID: #{c.id}, is_master_template: #{c.is_master_template})"
    end
  end
end