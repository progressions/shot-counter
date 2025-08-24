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
      
      # Skip image duplication for now due to ImageKit integration complexity  
      # TODO: Handle image duplication with ImageKit in a future update

      @duplicated_juncture
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
  end
end