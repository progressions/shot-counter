module DuplicateVehicleService
  class << self
    def duplicate(vehicle)
      base_name = vehicle.name[/^(.*?)\s*\(\d+\)\s*$/, 1] || vehicle.name
      current_number = vehicle.name.scan(/\((\d+)\)/).flatten.map(&:to_i).max.to_i

      new_name = "#{base_name} (#{current_number + 1})"

      # Check if the new name already exists in the database
      while Vehicle.exists?(name: new_name)
        current_number += 1
        new_name = "#{base_name} (#{current_number})"
      end

      # Create a new duplicate record with the unique name
      duplicated_vehicle = vehicle.dup
      duplicated_vehicle.name = new_name
      duplicated_vehicle.save

      duplicated_vehicle
    end
  end
end
