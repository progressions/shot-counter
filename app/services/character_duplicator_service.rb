module CharacterDuplicatorService
  class << self
    def duplicate_character(character, user, target_campaign = nil)
      attributes = character.attributes
      @duplicated_character = Character.new(attributes.except("id", "created_at", "updated_at", "user_id", "campaign_id"))
      # Use the target campaign if provided, otherwise fall back to the source character's campaign
      @duplicated_character.campaign = target_campaign || character.campaign
      @duplicated_character.user = user
      @duplicated_character = set_unique_name(@duplicated_character)
      
      # Store the original character's associations to be applied after save
      @duplicated_character.define_singleton_method(:source_schticks) { character.schticks }
      @duplicated_character.define_singleton_method(:source_weapons) { character.weapons }
      @duplicated_character.define_singleton_method(:source_image) { character.image if character.image.attached? }
      
      if character.image.attached?
        @duplicated_character.define_singleton_method(:attach_source_image) do
          self.image.attach(
            io: StringIO.new(character.image.blob.download),
            filename: character.image.blob.filename,
            content_type: character.image.blob.content_type
          )
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
      
      if duplicated_character.respond_to?(:attach_source_image)
        duplicated_character.attach_source_image
      end
    end

    def set_unique_name(character)
      return unless character.name.present?

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
  end
end
