module VehicleDuplicatorService
  class << self
    def duplicate_vehicle(vehicle, user, target_campaign)
      attributes = vehicle.attributes
      duplicated_vehicle = Vehicle.new(attributes.except("id", "created_at", "updated_at", "user_id", "campaign_id"))
      duplicated_vehicle.campaign = target_campaign
      duplicated_vehicle.user = user
      duplicated_vehicle = set_unique_name(duplicated_vehicle)
      
      if vehicle.image.attached?
        duplicated_vehicle.image.attach(
          io: StringIO.new(vehicle.image.blob.download),
          filename: vehicle.image.blob.filename,
          content_type: vehicle.image.blob.content_type
        )
      end
      
      # Store reference to source vehicle for image position copying
      duplicated_vehicle.instance_variable_set(:@source_vehicle, vehicle)

      duplicated_vehicle
    end
    
    def apply_associations(duplicated_vehicle)
      return unless duplicated_vehicle.persisted?
      
      # Copy image positions from source vehicle if we have a reference to it
      if duplicated_vehicle.instance_variable_defined?(:@source_vehicle)
        copy_image_positions(duplicated_vehicle.instance_variable_get(:@source_vehicle), duplicated_vehicle)
      end
    end

    private

    def set_unique_name(vehicle)
      original_name = vehicle.name
      counter = 1
      while Vehicle.where(campaign: vehicle.campaign, name: vehicle.name).exists?
        vehicle.name = "#{original_name} (#{counter})"
        counter += 1
      end
      vehicle
    end
    
    def copy_image_positions(source_entity, target_entity)
      return unless source_entity.respond_to?(:image_positions)
      
      source_entity.image_positions.each do |position|
        ImagePosition.create!(
          positionable: target_entity,
          context: position.context,
          x_position: position.x_position,
          y_position: position.y_position,
          style_overrides: position.style_overrides
        )
      end
    rescue StandardError => e
      Rails.logger.warn "Failed to copy image positions for #{target_entity.class.name} #{target_entity.id}: #{e.message}"
    end
  end
end