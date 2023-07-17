class AddCharacterReferenceToVehicle < ActiveRecord::Migration[7.0]
  def change
    add_reference :vehicles, :character, null: true, foreign_key: true, type: :uuid
  end
end
