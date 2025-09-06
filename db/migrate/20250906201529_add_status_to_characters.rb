class AddStatusToCharacters < ActiveRecord::Migration[8.0]
  def change
    add_column :characters, :status, :jsonb, default: []
    add_index :characters, :status, using: :gin
  end
end
