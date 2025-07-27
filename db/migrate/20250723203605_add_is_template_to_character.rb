class AddIsTemplateToCharacter < ActiveRecord::Migration[8.0]
  def change
    add_column :characters, :is_template, :boolean
  end
end
