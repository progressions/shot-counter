namespace :characters do
  task ensure_references: :environment do
    Character.find_each do |character|
      next unless character.fight_id
      fight = Fight.find(character.fight_id)
      fight.characters << character
    end
  end

  task convert_action_values: :environment do
    Character.find_each do |character|
      ["Guns", "Martial Arts", "Sorcery", "Scroungetech", "Genome", "Defense", "Toughness", "Speed", "Fortune", "Max Fortune", "Wounds"].each do |value|
        character.action_values[value] = character.action_values[value].to_i
      end
      character.save!
    end

    Vehicle.find_each do |vehicle|
      ["Acceleration", "Handling", "Squeal", "Frame", "Crunch", "Condition Points", "Chase Points"].each do |value|
        vehicle.action_values[value] = vehicle.action_values[value].to_i
      end
      vehicle.save!
    end
  end

  task update_all: :environment do
    Character.find_each do |character|
      character.save!
    end

    Vehicle.find_each do |vehicle|
      vehicle.save!
    end
  end
end
