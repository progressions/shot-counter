class AddFieldsToFight < ActiveRecord::Migration[8.0]
  def change
    add_column :fights, :started_at, :timestamp
    add_column :fights, :ended_at, :timestamp
    add_column :fights, :season, :integer
    add_column :fights, :session, :integer
  end
end
