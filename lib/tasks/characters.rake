namespace :characters do
  task ensure_references: :environment do
    Character.find_each do |character|
      next unless character.fight_id
      fight = Fight.find(character.fight_id)
      fight.characters << character
    end
  end

  task convert_factions: :environment do
    Character.find_each do |character|
      faction_name = character.action_values['Faction']
      if faction_name.present?
        faction = character.campaign.factions.find_or_create_by(name: faction_name)
        faction.characters << character
        faction.save!
      end
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
