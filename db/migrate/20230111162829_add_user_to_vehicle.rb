class AddUserToVehicle < ActiveRecord::Migration[7.0]
  def change
    add_reference :vehicles, :user, type: :uuid, null: true, foreign_key: true
  end
end
