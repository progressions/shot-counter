#!/usr/bin/env ruby

# Script to update all V2 controllers with proper ids filtering and cache keys

controllers = [
  'app/controllers/api/v2/schticks_controller.rb',
  'app/controllers/api/v2/vehicles_controller.rb',
  'app/controllers/api/v2/sites_controller.rb',
  'app/controllers/api/v2/parties_controller.rb',
  'app/controllers/api/v2/factions_controller.rb',
  'app/controllers/api/v2/junctures_controller.rb',
  'app/controllers/api/v2/fights_controller.rb',
  'app/controllers/api/v2/characters_controller.rb',
  'app/controllers/api/v2/campaigns_controller.rb',
  'app/controllers/api/v2/users_controller.rb'
]

controllers.each do |controller_path|
  puts "Updating #{controller_path}..."
  
  content = File.read(controller_path)
  
  # Update the ids filter logic
  content.gsub!(/if params\.key\?\("ids"\).*?\n.*?query = params\["ids"\]\.blank\? \? query\.where\(id: nil\) : query\.where\(id: params\["ids"\]\.split\(","\)\)\n.*?end/m) do
    'query = apply_ids_filter(query, params["ids"]) if params.key?("ids")'
  end
  
  # Alternative pattern for single line
  content.gsub!(/query = params\["ids"\]\.blank\? \? query\.where\(id: nil\) : query\.where\(id: params\["ids"\]\.split\(","\)\) if params\["ids"\]/) do
    'query = apply_ids_filter(query, params["ids"]) if params.key?("ids")'
  end
  
  # Update cache key to include id and ids parameters
  # Look for cache_key = [ pattern and add the id/ids lines after per_page
  content.gsub!(/(cache_key = \[.*?per_page,)/m) do |match|
    unless match.include?('params["id"]')
      match + "\n      params[\"id\"],\n      format_ids_for_cache(params[\"ids\"]),"
    else
      match
    end
  end
  
  File.write(controller_path, content)
  puts "  ✓ Updated #{controller_path}"
end

puts "\nAll controllers updated!"