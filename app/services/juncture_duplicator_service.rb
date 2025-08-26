module JunctureDuplicatorService
  class << self
    def duplicate_juncture(juncture, target_campaign, faction_mapping = {})
      attributes = juncture.attributes
      @duplicated_juncture = Juncture.new(attributes.except("id", "created_at", "updated_at", "campaign_id", "faction_id"))
      @duplicated_juncture.campaign = target_campaign
      @duplicated_juncture = set_unique_name(@duplicated_juncture)
      
      # Handle faction relationship if it exists and mapping is provided
      if juncture.faction && faction_mapping[juncture.faction.id]
        @duplicated_juncture.faction = faction_mapping[juncture.faction.id]
      end
      
      # Store reference to source juncture for image position copying
      @duplicated_juncture.instance_variable_set(:@source_juncture, juncture)
      
      # Skip image duplication for now due to ImageKit integration complexity  
      # TODO: Handle image duplication with ImageKit in a future update

      @duplicated_juncture
    end
    
    def apply_associations(duplicated_juncture)
      return unless duplicated_juncture.persisted?
      
      # Copy image positions from source juncture if we have a reference to it
      if duplicated_juncture.instance_variable_defined?(:@source_juncture)
        copy_image_positions(duplicated_juncture.instance_variable_get(:@source_juncture), duplicated_juncture)
      end
    end

    private

    def set_unique_name(juncture)
      return juncture unless juncture.name.present?

      base_name = juncture.name.strip
      if juncture.campaign.junctures.exists?(name: base_name)
        counter = 1
        new_name = "#{base_name} (#{counter})"

        while juncture.campaign.junctures.exists?(name: new_name)
          counter += 1
          new_name = "#{base_name} (#{counter})"
        end

        juncture.name = new_name
      end

      juncture
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