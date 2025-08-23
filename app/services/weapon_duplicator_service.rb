module WeaponDuplicatorService
  class << self
    def duplicate_weapon(weapon, target_campaign)
      attributes = weapon.attributes
      @duplicated_weapon = Weapon.new(attributes.except("id", "created_at", "updated_at", "campaign_id"))
      @duplicated_weapon.campaign = target_campaign
      @duplicated_weapon = set_unique_name(@duplicated_weapon)
      
      if weapon.image.attached?
        @duplicated_weapon.image.attach(
          io: StringIO.new(weapon.image.blob.download),
          filename: weapon.image.blob.filename,
          content_type: weapon.image.blob.content_type
        )
      end

      @duplicated_weapon
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
  end
end