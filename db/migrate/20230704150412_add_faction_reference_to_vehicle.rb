class AddFactionReferenceToVehicle < ActiveRecord::Migration[7.0]
  def change
    add_reference :vehicles, :faction, null: true, foreign_key: true, type: :uuid
  end
end
