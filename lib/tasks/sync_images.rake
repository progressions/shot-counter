namespace :campaign do
  desc "Sync images from master template to an existing campaign (matches by name, doesn't duplicate)"
  task :sync_images, [:campaign_id] => :environment do |task, args|
    require 'open-uri'
    require 'openssl'
    require 'stringio'

    unless args[:campaign_id]
      puts "❌ Usage: rails campaign:sync_images[CAMPAIGN_ID]"
      puts "   Or: rails campaign:sync_images[CAMPAIGN_ID] DRY_RUN=true"
      puts "   Or: rails campaign:sync_images[CAMPAIGN_ID] OVERWRITE=true"
      exit 1
    end

    dry_run = ENV['DRY_RUN'].to_s.downcase == 'true'
    overwrite = ENV['OVERWRITE'].to_s.downcase == 'true'

    # Find campaigns
    target_campaign = Campaign.find_by(id: args[:campaign_id])
    unless target_campaign
      puts "❌ Campaign not found with ID: #{args[:campaign_id]}"
      exit 1
    end

    master_template = Campaign.find_by(is_master_template: true)
    unless master_template
      puts "❌ No master template campaign found (is_master_template: true)"
      exit 1
    end

    if dry_run
      puts "\n🔍 DRY RUN MODE - No changes will be made"
    else
      puts "\n🚀 LIVE MODE - Images will be synced"
    end

    puts "📍 Source: #{master_template.name} (ID: #{master_template.id})"
    puts "📍 Target: #{target_campaign.name} (ID: #{target_campaign.id})"
    puts "🔄 Overwrite existing images: #{overwrite ? 'YES' : 'NO'}"
    puts "\n" + "=" * 60

    stats = {
      schticks_synced: 0,
      schticks_skipped: 0,
      weapons_synced: 0,
      weapons_skipped: 0,
      factions_synced: 0,
      factions_skipped: 0,
      characters_synced: 0,
      characters_skipped: 0,
      vehicles_synced: 0,
      vehicles_skipped: 0,
      errors: 0
    }

    # Sync schticks
    puts "\n🎯 Syncing Schtick Images..."
    sync_entity_images(
      master_template.schticks,
      target_campaign.schticks,
      'Schtick',
      dry_run,
      overwrite,
      stats,
      :schticks_synced,
      :schticks_skipped
    )

    # Sync weapons
    puts "\n🔫 Syncing Weapon Images..."
    sync_entity_images(
      master_template.weapons,
      target_campaign.weapons,
      'Weapon',
      dry_run,
      overwrite,
      stats,
      :weapons_synced,
      :weapons_skipped
    )

    # Sync factions
    puts "\n⚔️  Syncing Faction Images..."
    sync_entity_images(
      master_template.factions,
      target_campaign.factions,
      'Faction',
      dry_run,
      overwrite,
      stats,
      :factions_synced,
      :factions_skipped
    )

    # Sync characters
    puts "\n👤 Syncing Character Images..."
    sync_entity_images(
      master_template.characters,
      target_campaign.characters,
      'Character',
      dry_run,
      overwrite,
      stats,
      :characters_synced,
      :characters_skipped
    )

    # Sync vehicles
    puts "\n🚗 Syncing Vehicle Images..."
    sync_entity_images(
      master_template.vehicles,
      target_campaign.vehicles,
      'Vehicle',
      dry_run,
      overwrite,
      stats,
      :vehicles_synced,
      :vehicles_skipped
    )

    # Summary
    puts "\n" + "=" * 60
    puts "📊 Summary:"
    puts "  Schticks: #{stats[:schticks_synced]} synced, #{stats[:schticks_skipped]} skipped"
    puts "  Weapons: #{stats[:weapons_synced]} synced, #{stats[:weapons_skipped]} skipped"
    puts "  Factions: #{stats[:factions_synced]} synced, #{stats[:factions_skipped]} skipped"
    puts "  Characters: #{stats[:characters_synced]} synced, #{stats[:characters_skipped]} skipped"
    puts "  Vehicles: #{stats[:vehicles_synced]} synced, #{stats[:vehicles_skipped]} skipped"
    puts "  Errors: #{stats[:errors]}"

    if dry_run
      puts "\n💡 This was a dry run. To actually sync images, run without DRY_RUN:"
      puts "  rails campaign:sync_images[#{args[:campaign_id]}]"
    else
      puts "\n✅ Image sync completed!"
    end
  end

  def sync_entity_images(source_entities, target_entities, entity_type, dry_run, overwrite, stats, synced_key, skipped_key)
    # Build lookup hash by name
    target_by_name = target_entities.index_by(&:name)

    source_entities.each do |source_entity|
      # Find matching entity in target campaign by name
      target_entity = target_by_name[source_entity.name]

      unless target_entity
        # Source entity doesn't exist in target campaign, skip
        next
      end

      # Check if source has an image
      unless source_entity.image.attached?
        next
      end

      # Check if target already has an image
      if target_entity.image.attached? && !overwrite
        stats[skipped_key] += 1
        next
      end

      # Copy the image
      if dry_run
        puts "  Would sync image: #{source_entity.name}"
        stats[synced_key] += 1
      else
        begin
          # Use the exact same logic as CampaignSeederService.copy_campaign_image
          source_blob = source_entity.image.blob
          downloaded = source_blob.service.download(source_blob.key)

          # Handle ImageKit ActiveStorage adapter
          if downloaded.class.name == 'ImageKiIo::ActiveStorage::IKFile'
            url = downloaded.instance_variable_get(:@identifier)['url']

            image_data = nil
            begin
              URI.open(url) { |io| image_data = io.read }
            rescue OpenSSL::SSL::SSLError => ssl_error
              puts "  ⚠️  SSL error fetching #{source_entity.name}: #{ssl_error.message}"
            end
          elsif downloaded.is_a?(String)
            image_data = downloaded
          elsif downloaded.respond_to?(:read)
            image_data = downloaded.read
          else
            puts "  ⚠️  Unknown download object type for #{source_entity.name}: #{downloaded.class}"
            stats[skipped_key] += 1
            next
          end

          if image_data && image_data.bytesize > 0
            target_entity.image.attach(
              io: StringIO.new(image_data),
              filename: source_blob.filename,
              content_type: source_blob.content_type
            )
            puts "  ✅ Synced: #{source_entity.name} (#{image_data.bytesize} bytes)"
            stats[synced_key] += 1
          else
            puts "  ⚠️  No image data for #{source_entity.name}"
            stats[skipped_key] += 1
          end
        rescue => e
          puts "  ❌ Error syncing #{source_entity.name}: #{e.message}"
          stats[:errors] += 1
        end
      end
    end
  end
end
