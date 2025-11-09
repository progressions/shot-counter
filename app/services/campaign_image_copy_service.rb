module CampaignImageCopyService
  class << self
    def call(target_campaign:, source_campaign: nil, importer: ImageKitImporter, force: false, logger: Rails.logger, associations: [:schticks, :weapons, :factions])
      if associations.include?(:schticks)
        # collect schtick category images
        schtick_images_by_category = source_campaign.schticks
          .where.not(category: nil)
          .group_by(&:category)
          .transform_values { |schticks| schticks.find { |w| w.image_url.present? }&.image_url }
          .compact

        target_campaign.schticks.each do |b|
          begin
            image_for_category = schtick_images_by_category[b.category]

            ImageKitImporter.call(source_url: image_for_category, attachable: b)
          rescue StandardError => e
            puts e.inspect
          end
        end
      end

      # collect weapon category images
      if associations.include?(:weapons)
        weapon_images_by_category = source_campaign.weapons
          .where.not(category: nil)
          .group_by(&:category)
          .transform_values { |weapons| weapons.find { |w| w.image_url.present? }&.image_url }
          .compact

        target_campaign.weapons.each do |b|
          begin
            image_for_category = weapon_images_by_category[b.category]

            ImageKitImporter.call(source_url: image_for_category, attachable: b)

          rescue StandardError => e
            puts e.inspect
          end
        end
      end

      if associations.include?(:factions)
        source_campaign.factions.each do |a|
          puts "Copying image from #{a.name}..."
          begin
            b = target_campaign.factions.find_by(name: a.name)
            puts "...into #{b.name}"

            next unless a.image_url

            ImageKitImporter.call(source_url: a.image_url, attachable: b)
          rescue StandardError => e
            puts e.inspect
          end
        end
      end
    end
  end
end
