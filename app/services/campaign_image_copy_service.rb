module CampaignImageCopyService
  class << self
    def call(target_campaign:, source_campaign: nil, importer: ImageKitImporter, force: false, logger: Rails.logger)
      source_campaign.schticks.each do |a|
        puts "Copying image from #{a.name}..."
        begin
          b = target_campaign.schticks.find_by(name: a.name)
          puts "...into #{b.name}"

          next unless a.image_url

          ImageKitImporter.call(source_url: a.image_url, attachable: b)
        rescue StandardError => e
          puts e.inspect
        end
      end

      source_campaign.weapons.each do |a|
        puts "Copying image from #{a.name}..."
        begin
          b = target_campaign.weapons.find_by(name: a.name)
          puts "...into #{b.name}"

          next unless a.image_url

          ImageKitImporter.call(source_url: a.image_url, attachable: b)
        rescue StandardError => e
          puts e.inspect
        end
      end

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
