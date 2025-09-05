class AddWasRammedOrDamagedToShots < ActiveRecord::Migration[8.0]
  def change
    add_column :shots, :was_rammed_or_damaged, :boolean, default: false, null: false
    add_index :shots, :was_rammed_or_damaged
  end
end
