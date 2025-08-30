module SchtickDuplicatorService
  class << self
    def duplicate_schtick(schtick, target_campaign)
      attributes = schtick.attributes
      @duplicated_schtick = Schtick.new(attributes.except("id", "created_at", "updated_at", "campaign_id", "prerequisite_id"))
      @duplicated_schtick.campaign = target_campaign
      @duplicated_schtick.campaign_id = target_campaign.id  # Explicitly set campaign_id
      Rails.logger.info "[SchtickDuplicator] Setting campaign_id to #{target_campaign.id} for schtick #{@duplicated_schtick.name}"
      @duplicated_schtick = set_unique_name(@duplicated_schtick)
      Rails.logger.info "[SchtickDuplicator] After set_unique_name, campaign_id is #{@duplicated_schtick.campaign_id}"
      
      # Handle prerequisite relationships after all schticks are created
      # Store the original prerequisite info for later linking
      @duplicated_schtick.instance_variable_set(:@original_prerequisite, schtick.prerequisite)
      
      # Store reference to source schtick for image position copying
      @duplicated_schtick.instance_variable_set(:@source_schtick, schtick)
      
      if schtick.image.attached?
        begin
          # Handle ImageKit download - force read as string
          downloaded = schtick.image.blob.download
          image_data = downloaded.is_a?(String) ? downloaded : downloaded.read
          
          @duplicated_schtick.image.attach(
            io: StringIO.new(image_data),
            filename: schtick.image.blob.filename,
            content_type: schtick.image.blob.content_type
          )
        rescue => e
          Rails.logger.warn "Failed to duplicate image for schtick #{schtick.name}: #{e.message}"
        end
      end

      @duplicated_schtick
    end

    def link_prerequisites(duplicated_schticks, original_to_new_mapping)
      duplicated_schticks.each do |duplicated_schtick|
        original_prerequisite = duplicated_schtick.instance_variable_get(:@original_prerequisite)
        next unless original_prerequisite

        new_prerequisite = original_to_new_mapping[original_prerequisite.id]
        if new_prerequisite
          duplicated_schtick.prerequisite = new_prerequisite
          duplicated_schtick.save!
        end
      end
    end
    
    def apply_associations(duplicated_schtick)
      return unless duplicated_schtick.persisted?
      
      # Copy image positions from source schtick if we have a reference to it
      if duplicated_schtick.instance_variable_defined?(:@source_schtick)
        copy_image_positions(duplicated_schtick.instance_variable_get(:@source_schtick), duplicated_schtick)
      end
    end

    private

    def set_unique_name(schtick)
      return schtick unless schtick.name.present?

      base_name = schtick.name.strip
      if schtick.campaign.schticks.exists?(name: base_name)
        counter = 1
        new_name = "#{base_name} (#{counter})"

        while schtick.campaign.schticks.exists?(name: new_name)
          counter += 1
          new_name = "#{base_name} (#{counter})"
        end

        schtick.name = new_name
      end

      schtick
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