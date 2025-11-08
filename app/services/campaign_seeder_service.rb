class CampaignSeederService
  class << self
    def seed_campaign(campaign)
      Rails.logger.info "[CampaignSeederService] Starting seed_campaign for: #{campaign.name} (ID: #{campaign.id})"

      if campaign.seeded_at.present?
        Rails.logger.info "[CampaignSeederService] Campaign already seeded, seeded_at: #{campaign.seeded_at}"
        Rails.logger.info "Campaign already seeded, seeded_at: #{campaign.seeded_at}"
        return false
      end

      unless campaign.persisted?
        Rails.logger.info "Campaign not persisted"
        return false
      end

      master_template = Campaign.find_by(is_master_template: true)
      unless master_template
        Rails.logger.error "[CampaignSeederService] ERROR: No master template found!"
        Rails.logger.info "No master template found"
        return false
      end

      Rails.logger.info "[CampaignSeederService] Found master template: #{master_template.name} (ID: #{master_template.id})"

      Rails.logger.info "Seeding campaign #{campaign.name} (ID: #{campaign.id}) from master template"

      return copy_campaign_content(master_template, campaign)
    end

    def copy_campaign_content(source_campaign, target_campaign)
      return false unless source_campaign.persisted? && target_campaign.persisted?

      Rails.logger.info "Copying content from campaign #{source_campaign.name} to #{target_campaign.name}"

      # Check and fix blob sequence if needed (preventive measure)
      fix_blob_sequence_if_needed

      # Disable broadcasts during bulk seeding operations
      Thread.current[:disable_broadcasts] = true

      # Use a transaction but with proper connection handling
      ActiveRecord::Base.transaction do
        # Copy schticks and weapons first so they exist when characters reference them
        Rails.logger.info "Starting schtick duplication..."
        duplicate_schticks(source_campaign, target_campaign)

        Rails.logger.info "Starting weapon duplication..."
        duplicate_weapons(source_campaign, target_campaign)

        # Copy factions before junctures since junctures reference factions
        Rails.logger.info "Starting faction duplication..."
        duplicate_factions(source_campaign, target_campaign)

        Rails.logger.info "Starting juncture duplication..."
        duplicate_junctures(source_campaign, target_campaign)

        # Copy characters and vehicles last so they can reference the duplicated entities
        Rails.logger.info "Starting character duplication..."
        duplicate_characters(source_campaign, target_campaign)

        Rails.logger.info "Starting vehicle duplication..."
        duplicate_vehicles(source_campaign, target_campaign)

        # Copy non-template characters from Master Campaign (if it exists)
        Rails.logger.info "Copying master campaign characters..."
        copy_master_campaign_characters(target_campaign)

        # Copy the campaign's own image positions
        Rails.logger.info "Copying image positions..."
        copy_image_positions(source_campaign, target_campaign)

        # Copy the campaign's main image
        copy_campaign_image(source_campaign, target_campaign)

        # Mark campaign as seeded only if this was called from seed_campaign
        target_campaign.update!(seeded_at: Time.current) if target_campaign.seeded_at.nil?
      end

      Rails.logger.info "Successfully copied content to campaign #{target_campaign.name}"

      # Send a single reload broadcast after all content is copied
      BroadcastCampaignReloadJob.perform_later("Campaign", target_campaign.id)

      true
    rescue StandardError => e
      Rails.logger.error "Failed to copy campaign content: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      false
    ensure
      # Re-enable broadcasts
      Thread.current[:disable_broadcasts] = false
    end

    private

    def copy_master_campaign_characters(target_campaign)
      master_campaign = Campaign.find_by(name: 'Master Campaign')

      unless master_campaign
        Rails.logger.info "No Master Campaign found, skipping non-template character copying"
        return
      end

      Rails.logger.info "Copying non-template characters from Master Campaign to #{target_campaign.name}"

      # Get all non-template characters from Master Campaign
      characters_to_copy = master_campaign.characters.where(is_template: false)

      Rails.logger.info "Found #{characters_to_copy.count} non-template characters to copy"

      characters_to_copy.each do |character|
        begin
          # Use CharacterDuplicatorService to copy the character
          duplicated_character = CharacterDuplicatorService.duplicate_character(
            character,
            target_campaign.user,
            target_campaign
          )

          if duplicated_character.save
            CharacterDuplicatorService.apply_associations(duplicated_character)
            # Image positions are now copied within apply_associations
            Rails.logger.info "Copied character: #{duplicated_character.name} from Master Campaign"
          else
            Rails.logger.error "Failed to copy character #{character.name} from Master Campaign: #{duplicated_character.errors.full_messages.join(', ')}"
          end
        rescue StandardError => e
          Rails.logger.error "Error copying character #{character.name} from Master Campaign: #{e.message}"
        end
      end
    end

    def duplicate_characters(source_campaign, target_campaign)
      characters = source_campaign.characters.where(is_template: true)

      Rails.logger.info "Duplicating #{characters.count} characters"

      # Process characters in batches
      batch_size = 5  # Characters are complex with many associations, use smaller batch
      character_count = 0

      characters.find_in_batches(batch_size: batch_size).with_index do |batch, batch_index|
        Rails.logger.info "Processing character batch #{batch_index + 1} (#{batch.size} items)"

        batch.each do |character|
          # Ensure connection is active
          ActiveRecord::Base.connection.verify!
          character_count += 1

          begin
            # Pass the target_campaign as the third parameter so it uses the correct campaign for name checking
            duplicated_character = CharacterDuplicatorService.duplicate_character(character, target_campaign.user, target_campaign)

            if duplicated_character.save
              # Apply associations after the character is saved and has an ID
              # This also copies image positions
              CharacterDuplicatorService.apply_associations(duplicated_character)

              Rails.logger.info "Duplicated character #{character_count}/#{characters.count}: #{duplicated_character.name}"
            else
              Rails.logger.error "Failed to duplicate character #{character.name}: #{duplicated_character.errors.full_messages.join(', ')}"
              raise ActiveRecord::RecordInvalid, duplicated_character
            end
          rescue ActiveRecord::StatementInvalid => e
            if e.message.include?("connection") || e.message.include?("closed")
              Rails.logger.warn "Connection lost, reconnecting and retrying character: #{character.name}"
              ActiveRecord::Base.connection.reconnect!
              retry
            else
              raise
            end
          end
        end

        # Pause between batches
        if batch_index < (characters.count.to_f / batch_size).ceil - 1
          sleep(0.5)
        end
      end
    end

    def duplicate_vehicles(source_campaign, target_campaign)
      vehicles = source_campaign.vehicles

      Rails.logger.info "Duplicating #{vehicles.count} vehicles"

      vehicles.each do |vehicle|
        duplicated_vehicle = VehicleDuplicatorService.duplicate_vehicle(vehicle, target_campaign.user, target_campaign)

        if duplicated_vehicle.save
          # Apply associations including image positions
          VehicleDuplicatorService.apply_associations(duplicated_vehicle)

          Rails.logger.info "Duplicated vehicle: #{duplicated_vehicle.name}"
        else
          Rails.logger.error "Failed to duplicate vehicle #{vehicle.name}: #{duplicated_vehicle.errors.full_messages.join(', ')}"
          raise ActiveRecord::RecordInvalid, duplicated_vehicle
        end
      end
    end

    def duplicate_schticks(source_campaign, target_campaign)
      schticks = source_campaign.schticks

      Rails.logger.info "Duplicating #{schticks.count} schticks"

      # Keep track of original to new mapping for prerequisites
      original_to_new_mapping = {}
      duplicated_schticks = []

      # Process schticks in smaller batches to prevent connection timeouts
      batch_size = 5
      schticks.find_in_batches(batch_size: batch_size).with_index do |batch, batch_index|
        Rails.logger.info "Processing schtick batch #{batch_index + 1} (#{batch.size} items)"

        batch.each_with_index do |schtick, index|
          # Ensure connection is active before each schtick
          ActiveRecord::Base.connection.verify!

          begin
            duplicated_schtick = SchtickDuplicatorService.duplicate_schtick(schtick, target_campaign)

            if duplicated_schtick.save
              # Track the mapping for prerequisite linking
              original_to_new_mapping[schtick.id] = duplicated_schtick
              duplicated_schticks << duplicated_schtick

              # Apply associations including image positions
              SchtickDuplicatorService.apply_associations(duplicated_schtick)

              Rails.logger.info "Duplicated schtick #{(batch_index * batch_size) + index + 1}/#{schticks.count}: #{duplicated_schtick.name}"
            else
              Rails.logger.error "Failed to duplicate schtick #{schtick.name}: #{duplicated_schtick.errors.full_messages.join(', ')}"
              raise ActiveRecord::RecordInvalid, duplicated_schtick
            end
          rescue ActiveRecord::StatementInvalid => e
            if e.message.include?("connection") || e.message.include?("closed")
              Rails.logger.warn "Connection lost, reconnecting and retrying schtick: #{schtick.name}"
              ActiveRecord::Base.connection.reconnect!
              retry
            else
              raise
            end
          rescue NoMethodError => e
            if e.message.include?("async_exec") && e.message.include?("nil")
              Rails.logger.warn "Database connection nil, reconnecting and retrying schtick: #{schtick.name}"
              ActiveRecord::Base.clear_active_connections!
              ActiveRecord::Base.connection.reconnect!
              sleep(1)
              retry
            else
              raise
            end
          end

          # Add small delay between schticks to prevent overwhelming the connection
          sleep(0.1) if index > 0 && index % 5 == 0
        end

        # Longer pause between batches
        if batch_index < (schticks.count.to_f / batch_size).ceil - 1
          Rails.logger.info "Pausing between batches to maintain connection stability..."
          sleep(1)
        end
      end

      # Now link all the prerequisites after all schticks are created
      Rails.logger.info "Linking prerequisites for #{duplicated_schticks.count} duplicated schticks..."
      SchtickDuplicatorService.link_prerequisites(duplicated_schticks, original_to_new_mapping)
      Rails.logger.info "Linked prerequisites for duplicated schticks"
    end

    def duplicate_weapons(source_campaign, target_campaign)
      weapons = source_campaign.weapons

      Rails.logger.info "Duplicating #{weapons.count} weapons"

      # Process weapons in batches to prevent connection timeouts
      batch_size = 20  # Weapons are simpler than schticks, can use larger batch
      weapons.find_in_batches(batch_size: batch_size).with_index do |batch, batch_index|
        Rails.logger.info "Processing weapon batch #{batch_index + 1} (#{batch.size} items)"

        batch.each_with_index do |weapon, index|
          # Ensure connection is active
          ActiveRecord::Base.connection.verify!

          begin
            duplicated_weapon = WeaponDuplicatorService.duplicate_weapon(weapon, target_campaign)

            if duplicated_weapon.save
              # Apply associations including image positions
              WeaponDuplicatorService.apply_associations(duplicated_weapon)

              Rails.logger.info "Duplicated weapon #{(batch_index * batch_size) + index + 1}/#{weapons.count}: #{duplicated_weapon.name}"
            else
              Rails.logger.error "Failed to duplicate weapon #{weapon.name}: #{duplicated_weapon.errors.full_messages.join(', ')}"
              raise ActiveRecord::RecordInvalid, duplicated_weapon
            end
          rescue ActiveRecord::StatementInvalid => e
            if e.message.include?("connection") || e.message.include?("closed")
              Rails.logger.warn "Connection lost, reconnecting and retrying weapon: #{weapon.name}"
              ActiveRecord::Base.connection.reconnect!
              retry
            else
              raise
            end
          end
        end

        # Pause between batches if more to come
        if batch_index < (weapons.count.to_f / batch_size).ceil - 1
          sleep(0.5)
        end
      end
    end

    def duplicate_junctures(source_campaign, target_campaign)
      junctures = source_campaign.junctures

      Rails.logger.info "Duplicating #{junctures.count} junctures"

      # Create faction mapping for juncture associations
      faction_mapping = {}
      source_campaign.factions.each do |source_faction|
        target_faction = target_campaign.factions.find_by(name: source_faction.name)
        faction_mapping[source_faction.id] = target_faction if target_faction
      end

      junctures.each do |juncture|
        duplicated_juncture = JunctureDuplicatorService.duplicate_juncture(juncture, target_campaign, faction_mapping)

        if duplicated_juncture.save
          # Apply associations including image positions
          JunctureDuplicatorService.apply_associations(duplicated_juncture)

          Rails.logger.info "Duplicated juncture: #{duplicated_juncture.name}"
        else
          Rails.logger.error "Failed to duplicate juncture #{juncture.name}: #{duplicated_juncture.errors.full_messages.join(', ')}"
          raise ActiveRecord::RecordInvalid, duplicated_juncture
        end
      end
    end

    def duplicate_factions(source_campaign, target_campaign)
      factions = source_campaign.factions

      Rails.logger.info "Duplicating #{factions.count} factions"

      factions.each do |faction|
        duplicated_faction = FactionDuplicatorService.duplicate_faction(faction, target_campaign)

        if duplicated_faction.save
          # Apply associations including image positions
          FactionDuplicatorService.apply_associations(duplicated_faction)

          Rails.logger.info "Duplicated faction: #{duplicated_faction.name}"
        else
          Rails.logger.error "Failed to duplicate faction #{faction.name}: #{duplicated_faction.errors.full_messages.join(', ')}"
          raise ActiveRecord::RecordInvalid, duplicated_faction
        end
      end
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

      Rails.logger.info "Copied #{source_entity.image_positions.count} image positions for #{target_entity.class.name} #{target_entity.id}"
    rescue StandardError => e
      Rails.logger.warn "Failed to copy image positions for #{target_entity.class.name} #{target_entity.id}: #{e.message}"
    end

    def copy_campaign_image(source_campaign, target_campaign)
      return unless source_campaign.image.attached?

      Rails.logger.info "Copying campaign image from #{source_campaign.name} to #{target_campaign.name}"

      begin
        # Use the same ImageKit-aware download logic as CharacterDuplicatorService
        downloaded = source_campaign.image.blob.service.download(source_campaign.image.blob.key)

        # Handle ImageKit ActiveStorage adapter
        if downloaded.class.name == 'ImageKiIo::ActiveStorage::IKFile'
          Rails.logger.info "ImageKit IKFile detected for campaign image, fetching via URL..."
          require 'net/http'
          uri = URI(downloaded.instance_variable_get(:@identifier)['url'])
          image_data = Net::HTTP.get(uri)
        elsif downloaded.is_a?(String)
          image_data = downloaded
        elsif downloaded.respond_to?(:read)
          image_data = downloaded.read
        else
          Rails.logger.warn "Unknown campaign image download object type: #{downloaded.class}"
          return
        end

        if image_data && image_data.bytesize > 0
          target_campaign.image.attach(
            io: StringIO.new(image_data),
            filename: source_campaign.image.blob.filename,
            content_type: source_campaign.image.blob.content_type
          )
          Rails.logger.info "Successfully copied campaign image: #{source_campaign.image.blob.filename} (#{image_data.bytesize} bytes)"
        end
      rescue => e
        Rails.logger.error "Failed to copy campaign image: #{e.class} - #{e.message}"
      end
    end

    def fix_blob_sequence_if_needed
      # Fix both blob and attachment sequences
      ['active_storage_blobs', 'active_storage_attachments'].each do |table|
        begin
          max_id = ActiveRecord::Base.connection.execute(
            "SELECT MAX(id) FROM #{table}"
          ).first['max'].to_i

          sequence_value = ActiveRecord::Base.connection.execute(
            "SELECT last_value FROM #{table}_id_seq"
          ).first['last_value'].to_i

          if sequence_value <= max_id
            Rails.logger.warn "[CampaignSeederService] #{table} sequence out of sync! Sequence: #{sequence_value}, Max ID: #{max_id}"
            next_id = max_id + 1

            ActiveRecord::Base.connection.execute(
              "SELECT setval('#{table}_id_seq', #{next_id}, false)"
            )

            Rails.logger.info "[CampaignSeederService] Fixed #{table} sequence. Next ID will be: #{next_id}"
          end
        rescue => e
          Rails.logger.error "[CampaignSeederService] Failed to check/fix #{table} sequence: #{e.message}"
        end
      end
    end
  end
end
