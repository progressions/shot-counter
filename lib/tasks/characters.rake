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
      character.save!
    end

    Vehicle.find_each do |vehicle|
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
