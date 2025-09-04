class RemovePositionFromVehicles < ActiveRecord::Migration[8.0]
  def up
    # Remove Position field from vehicles' action_values JSONB
    Vehicle.find_each do |vehicle|
      if vehicle.action_values.present? && vehicle.action_values.key?("Position")
        vehicle.action_values.delete("Position")
        vehicle.save!(validate: false)
      end
    end
  end

  def down
    # Restore Position field with default value
    Vehicle.find_each do |vehicle|
      if vehicle.action_values.present?
        vehicle.action_values["Position"] = "far"
        vehicle.save!(validate: false)
      end
    end
  end
end
