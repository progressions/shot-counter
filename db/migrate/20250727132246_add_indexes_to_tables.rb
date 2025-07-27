class AddIndexesToTables < ActiveRecord::Migration[8.0]
  def change
    # Add GIN index for JSONB queries on characters.action_values
    add_index :characters, :action_values, using: :gin
  end
end
