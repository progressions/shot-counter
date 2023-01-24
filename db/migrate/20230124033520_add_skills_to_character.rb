class AddSkillsToCharacter < ActiveRecord::Migration[7.0]
  def change
    add_column :characters, :skills, :jsonb
  end
end
