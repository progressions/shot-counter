module FactionDuplicatorService
  class << self
    def duplicate_faction(faction, target_campaign)
      attributes = faction.attributes
      @duplicated_faction = Faction.new(attributes.except("id", "created_at", "updated_at", "campaign_id"))
      @duplicated_faction.campaign = target_campaign
      @duplicated_faction = set_unique_name(@duplicated_faction)
      
      # Store reference to source faction for image position copying
      @duplicated_faction.instance_variable_set(:@source_faction, faction)
      
      # Skip image duplication for now due to ImageKit integration complexity
      # TODO: Handle image duplication with ImageKit in a future update

      @duplicated_faction
    end
    
    def apply_associations(duplicated_faction)
      return unless duplicated_faction.persisted?
      
      # Copy image positions from source faction if we have a reference to it
      if duplicated_faction.instance_variable_defined?(:@source_faction)
        copy_image_positions(duplicated_faction.instance_variable_get(:@source_faction), duplicated_faction)
      end
    end

    private

    def set_unique_name(faction)
      return faction unless faction.name.present?

      base_name = faction.name.strip
      if faction.campaign.factions.exists?(name: base_name)
        counter = 1
        new_name = "#{base_name} (#{counter})"

        while faction.campaign.factions.exists?(name: new_name)
          counter += 1
          new_name = "#{base_name} (#{counter})"
        end

        faction.name = new_name
      end

      faction
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