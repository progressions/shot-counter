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

      duplicated_vehicle
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
  end
end