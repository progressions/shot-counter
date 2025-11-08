module WeaponDuplicatorService
  class << self
    def duplicate_weapon(weapon, target_campaign)
      attributes = weapon.attributes
      @duplicated_weapon = Weapon.new(attributes.except("id", "created_at", "updated_at", "campaign_id"))
      @duplicated_weapon.campaign = target_campaign
      @duplicated_weapon.campaign_id = target_campaign.id  # Explicitly set campaign_id
      @duplicated_weapon = set_unique_name(@duplicated_weapon)

      # Store reference to source weapon for image position copying
      @duplicated_weapon.instance_variable_set(:@source_weapon, weapon)

      if weapon.image_url.present?
        begin
          ImageKitImporter.call(source_url: weapon.image_url, attachable: @duplicated_weapon)
        rescue => e
          Rails.logger.warn "Failed to duplicate image for weapon #{weapon.name}: #{e.message}"
        end
      end

      @duplicated_weapon
    end

    def apply_associations(duplicated_weapon)
      return unless duplicated_weapon.persisted?

      # Copy image positions from source weapon if we have a reference to it
      if duplicated_weapon.instance_variable_defined?(:@source_weapon)
        copy_image_positions(duplicated_weapon.instance_variable_get(:@source_weapon), duplicated_weapon)
      end
    end

    private

    def set_unique_name(weapon)
      return weapon unless weapon.name.present?

      base_name = weapon.name.strip
      if weapon.campaign.weapons.exists?(name: base_name)
        counter = 1
        new_name = "#{base_name} (#{counter})"

        while weapon.campaign.weapons.exists?(name: new_name)
          counter += 1
          new_name = "#{base_name} (#{counter})"
        end

        weapon.name = new_name
      end

      weapon
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
