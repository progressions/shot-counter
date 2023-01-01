task update_values: :environment do
  Character.find_each do |character|
    character.action_values ||= {}
    character.action_values.merge!(Character::DEFAULT_ACTION_VALUES)
    character.save!
  end
end
