class AddActionValuesToCharacter < ActiveRecord::Migration[7.0]
  def change
    add_column :characters, :action_values, :jsonb
  end
end
