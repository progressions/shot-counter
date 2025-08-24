module FactionDuplicatorService
  class << self
    def duplicate_faction(faction, target_campaign)
      attributes = faction.attributes
      @duplicated_faction = Faction.new(attributes.except("id", "created_at", "updated_at", "campaign_id"))
      @duplicated_faction.campaign = target_campaign
      @duplicated_faction = set_unique_name(@duplicated_faction)
      
      # Skip image duplication for now due to ImageKit integration complexity
      # TODO: Handle image duplication with ImageKit in a future update

      @duplicated_faction
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
  end
end