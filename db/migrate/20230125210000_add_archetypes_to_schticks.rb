class AddArchetypesToSchticks < ActiveRecord::Migration[7.0]
  def change
    add_column :schticks, :archetypes, :jsonb
  end
end
