module SchtickDuplicatorService
  class << self
    def duplicate_schtick(schtick, target_campaign)
      attributes = schtick.attributes
      @duplicated_schtick = Schtick.new(attributes.except("id", "created_at", "updated_at", "campaign_id", "prerequisite_id"))
      @duplicated_schtick.campaign = target_campaign
      @duplicated_schtick = set_unique_name(@duplicated_schtick)
      
      # Handle prerequisite relationships after all schticks are created
      # Store the original prerequisite info for later linking
      @duplicated_schtick.instance_variable_set(:@original_prerequisite, schtick.prerequisite)
      
      if schtick.image.attached?
        @duplicated_schtick.image.attach(
          io: StringIO.new(schtick.image.blob.download),
          filename: schtick.image.blob.filename,
          content_type: schtick.image.blob.content_type
        )
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
  end
end