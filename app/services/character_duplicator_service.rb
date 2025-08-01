module CharacterDuplicatorService
  class << self
    def duplicate_character(character, user)
      attributes = character.attributes
      @duplicated_character = Character.new(attributes.except("id", "created_at", "updated_at", "user_id", "campaign_id"))
      @duplicated_character.campaign = character.campaign
      @duplicated_character.user = user
      @duplicated_character.schticks = character.schticks
      @duplicated_character.weapons = character.weapons
      @duplicated_character = set_unique_name(@duplicated_character)

      @duplicated_character
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
