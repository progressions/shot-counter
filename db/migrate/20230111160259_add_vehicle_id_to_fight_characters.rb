class AddVehicleIdToFightCharacters < ActiveRecord::Migration[7.0]
  def change
    add_reference :fight_characters, :vehicle, type: :uuid, null: true
    change_column :fight_characters, :character_id, :uuid, null: true
  end
end
