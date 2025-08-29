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
            Rails.logger.info "Starting image duplication for character #{character.name}"
            Rails.logger.info "Source image key: #{character.image.blob.key}"
            Rails.logger.info "Source image size: #{character.image.blob.byte_size} bytes"
            
            # Try multiple approaches to get image data
            image_data = nil
            
            # Handle ImageKit ActiveStorage adapter specifically
            begin
              Rails.logger.info "Trying blob service download..."
              downloaded = character.image.blob.service.download(character.image.blob.key)
              
              # Check if this is an ImageKit IKFile object
              if downloaded.class.name == 'ImageKiIo::ActiveStorage::IKFile'
                Rails.logger.info "ImageKit IKFile detected, fetching via URL..."
                # Use the URL from the ImageKit object to download the actual file data
                require 'net/http'
                uri = URI(downloaded.instance_variable_get(:@identifier)['url'])
                image_data = Net::HTTP.get(uri)
                Rails.logger.info "ImageKit URL download successful, size: #{image_data.bytesize} bytes"
              elsif downloaded.is_a?(String)
                image_data = downloaded
                Rails.logger.info "Direct string download successful, size: #{image_data.bytesize} bytes"
              elsif downloaded.respond_to?(:read)
                image_data = downloaded.read
                Rails.logger.info "Stream read successful, size: #{image_data.bytesize} bytes"
              else
                Rails.logger.warn "Unknown download object type: #{downloaded.class}"
                Rails.logger.warn "Available methods: #{downloaded.methods.grep(/read|data|string|url/)}"
                return
              end
            rescue => error
              Rails.logger.error "Image download failed: #{error.class} - #{error.message}"
              return
            end
            
            if image_data && image_data.bytesize > 0
              self.image.attach(
                io: StringIO.new(image_data),
                filename: character.image.blob.filename,
                content_type: character.image.blob.content_type
              )
              Rails.logger.info "Successfully attached image for character #{character.name}, size: #{image_data.bytesize} bytes"
            else
              Rails.logger.error "No valid image data obtained for character #{character.name}"
            end
          rescue => e
            Rails.logger.error "Failed to duplicate image for character #{character.name}: #{e.class} - #{e.message}"
            Rails.logger.error "Backtrace: #{e.backtrace.first(5).join('\n')}"
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
