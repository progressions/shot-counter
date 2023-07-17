class RemoveCharacterReferenceFromVehicle < ActiveRecord::Migration[7.0]
  def change
    remove_reference :vehicles, :character, null: false, foreign_key: true
  end
end
