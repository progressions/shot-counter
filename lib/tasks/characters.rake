namespace :characters do
  task ensure_references: :environment do
    Character.find_each do |character|
      next unless character.fight_id
      fight = Fight.find(character.fight_id)
      fight.characters << character
    end
  end
end
