class RemoveTitleFromCharacterEffects < ActiveRecord::Migration[7.0]
  def change
    CharacterEffect.find_each do |character_effect|
      character_effect.update(name: character_effect.title)
    end

    remove_column :character_effects, :title
  rescue StandardError
  end
end
