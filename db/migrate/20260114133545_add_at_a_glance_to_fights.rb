class AddAtAGlanceToFights < ActiveRecord::Migration[8.0]
  def change
    add_column :fights, :at_a_glance, :boolean, default: false, null: false
  end
end
