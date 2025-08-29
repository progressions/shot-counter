module CharacterDuplicatorService
  class << self
    def duplicate_character(character, user, target_campaign = nil)
      attributes = character.attributes
      @duplicated_character = Character.new(attributes.except("id", "created_at", "updated_at", "user_id", "campaign_id", "juncture_id", "faction_id"))
      # Use the target campaign if provided, otherwise fall back to the source character's campaign
      @duplicated_character.campaign = target_campaign || character.campaign
      @duplicated_character.user = user
      @duplicated_character = set_unique_name(@duplicated_character)
      
      # Store the original character's associations to be applied after save
      @duplicated_character.define_singleton_method(:source_schticks) { character.schticks }
      @duplicated_character.define_singleton_method(:source_weapons) { character.weapons }
      @duplicated_character.define_singleton_method(:source_juncture) { character.juncture }
      @duplicated_character.define_singleton_method(:source_faction) { character.faction }
      @duplicated_character.define_singleton_method(:source_image) { character.image if character.image.attached? }
      
      # Store reference to source character for image position copying
      @duplicated_character.instance_variable_set(:@source_character, character)
      
      if character.image.attached?
        @duplicated_character.define_singleton_method(:attach_source_image) do
          begin
            # Handle ImageKit download - force read as string
            downloaded = character.image.blob.download
            image_data = downloaded.is_a?(String) ? downloaded : downloaded.read
            
            self.image.attach(
              io: StringIO.new(image_data),
              filename: character.image.blob.filename,
              content_type: character.image.blob.content_type
            )
          rescue => e
            Rails.logger.warn "Failed to duplicate image for character #{character.name}: #{e.message}"
          end
        end
      end

      @duplicated_character
    end
    
    def apply_associations(duplicated_character)
      return unless duplicated_character.persisted?
      
      if duplicated_character.respond_to?(:source_schticks)
        # Find matching schticks in the target campaign by name
        source_schtick_names = duplicated_character.source_schticks.pluck(:name)
        target_schticks = duplicated_character.campaign.schticks.where(name: source_schtick_names)
        duplicated_character.schticks = target_schticks
      end
      
      if duplicated_character.respond_to?(:source_weapons)
        # Find matching weapons in the target campaign by name
        source_weapon_names = duplicated_character.source_weapons.pluck(:name)
        target_weapons = duplicated_character.campaign.weapons.where(name: source_weapon_names)
        duplicated_character.weapons = target_weapons
      end
      
      if duplicated_character.respond_to?(:source_juncture) && duplicated_character.source_juncture
        # Find matching juncture in the target campaign by name
        target_juncture = duplicated_character.campaign.junctures.find_by(name: duplicated_character.source_juncture.name)
        duplicated_character.update!(juncture: target_juncture) if target_juncture
      end
      
      if duplicated_character.respond_to?(:source_faction) && duplicated_character.source_faction
        # Find matching faction in the target campaign by name
        target_faction = duplicated_character.campaign.factions.find_by(name: duplicated_character.source_faction.name)
        duplicated_character.update!(faction: target_faction) if target_faction
      end
      
      if duplicated_character.respond_to?(:attach_source_image)
        duplicated_character.attach_source_image
      end
      
      # Copy image positions from source character if we have a reference to it
      if duplicated_character.instance_variable_defined?(:@source_character)
        copy_image_positions(duplicated_character.instance_variable_get(:@source_character), duplicated_character)
      end
    end

    def set_unique_name(character)
      return character unless character.name.present?

      base_name = character.name.strip
      if character.campaign.characters.exists?(name: base_name)
        counter = 1
        new_name = "#{base_name} (#{counter})"

        while character.campaign.characters.exists?(name: new_name)
          counter += 1
          new_name = "#{base_name} (#{counter})"
        end

        character.name = new_name
      end

      character
    end
    
    private
    
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
