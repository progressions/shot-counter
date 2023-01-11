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
  end
end
