class CampaignTemplateSyncService
  attr_reader :source_campaign, :target_campaign, :dry_run, :changes

  def initialize(target_campaign_id, source_campaign_id: nil, dry_run: true)
    @target_campaign = Campaign.find(target_campaign_id)
    @source_campaign = source_campaign_id ? Campaign.find(source_campaign_id) : Campaign.find_by(is_master_template: true)
    @dry_run = dry_run
    @changes = {
      schticks_updated: [],
      schticks_skipped: [],
      weapons_updated: [],
      weapons_skipped: [],
      characters_copied: [],
      characters_skipped: [],
      errors: []
    }

    raise "No source campaign found" unless @source_campaign
    raise "Target campaign not found" unless @target_campaign
  end

  def sync!
    log_header

    if @dry_run
      Rails.logger.info "[DRY RUN] Preview mode - no changes will be made"
      puts "\n=== DRY RUN MODE - NO CHANGES WILL BE MADE ===\n\n"
    end

    ActiveRecord::Base.transaction do
      sync_schticks
      sync_weapons
      sync_template_characters

      if @dry_run
        raise ActiveRecord::Rollback
      end
    end

    print_summary
    @changes
  end

  private

  def log_header
    Rails.logger.info "=" * 80
    Rails.logger.info "Campaign Template Sync"
    Rails.logger.info "Source: #{@source_campaign.name} (ID: #{@source_campaign.id})"
    Rails.logger.info "Target: #{@target_campaign.name} (ID: #{@target_campaign.id})"
    Rails.logger.info "Mode: #{@dry_run ? 'DRY RUN' : 'LIVE'}"
    Rails.logger.info "=" * 80

    puts "\n" + "=" * 80
    puts "Campaign Template Sync"
    puts "Source: #{@source_campaign.name} (ID: #{@source_campaign.id})"
    puts "Target: #{@target_campaign.name} (ID: #{@target_campaign.id})"
    puts "Mode: #{@dry_run ? 'DRY RUN' : 'LIVE'}"
    puts "=" * 80 + "\n\n"
  end

  def sync_schticks
    Rails.logger.info "\n--- Syncing Schticks ---"
    puts "\n--- Syncing Schticks ---\n"

    source_schticks = @source_campaign.schticks
    puts "Found #{source_schticks.count} schticks in source campaign\n\n"

    source_schticks.each do |source_schtick|
      # Find matching schtick by name in target campaign
      target_schtick = @target_campaign.schticks.find_by(name: source_schtick.name)

      if target_schtick
        changes = calculate_schtick_changes(source_schtick, target_schtick)

        if changes.any?
          log_schtick_update(source_schtick, target_schtick, changes)

          unless @dry_run
            update_schtick(target_schtick, source_schtick, changes)
          end

          @changes[:schticks_updated] << {
            name: target_schtick.name,
            id: target_schtick.id,
            changes: changes
          }
        else
          @changes[:schticks_skipped] << {
            name: target_schtick.name,
            reason: "No changes needed"
          }
        end
      else
        @changes[:schticks_skipped] << {
          name: source_schtick.name,
          reason: "Not found in target campaign"
        }
      end
    rescue StandardError => e
      error_msg = "Error syncing schtick #{source_schtick.name}: #{e.message}"
      Rails.logger.error error_msg
      @changes[:errors] << error_msg
    end
  end

  def sync_weapons
    Rails.logger.info "\n--- Syncing Weapons ---"
    puts "\n--- Syncing Weapons ---\n"

    source_weapons = @source_campaign.weapons
    puts "Found #{source_weapons.count} weapons in source campaign\n\n"

    source_weapons.each do |source_weapon|
      # Find matching weapon by name in target campaign
      target_weapon = @target_campaign.weapons.find_by(name: source_weapon.name)

      if target_weapon
        changes = calculate_weapon_changes(source_weapon, target_weapon)

        if changes.any?
          log_weapon_update(source_weapon, target_weapon, changes)

          unless @dry_run
            update_weapon(target_weapon, source_weapon, changes)
          end

          @changes[:weapons_updated] << {
            name: target_weapon.name,
            id: target_weapon.id,
            changes: changes
          }
        else
          @changes[:weapons_skipped] << {
            name: target_weapon.name,
            reason: "No changes needed"
          }
        end
      else
        @changes[:weapons_skipped] << {
          name: source_weapon.name,
          reason: "Not found in target campaign"
        }
      end
    rescue StandardError => e
      error_msg = "Error syncing weapon #{source_weapon.name}: #{e.message}"
      Rails.logger.error error_msg
      @changes[:errors] << error_msg
    end
  end

  def sync_template_characters
    Rails.logger.info "\n--- Syncing Template Characters ---"
    puts "\n--- Syncing Template Characters ---\n"

    # Find all template characters from source campaign
    template_characters = @source_campaign.characters.where(is_template: true)
    puts "Found #{template_characters.count} template characters in source campaign\n\n"

    template_characters.each do |source_character|
      # Check if character already exists in target campaign by name
      existing = @target_campaign.characters.find_by(name: source_character.name)

      if existing
        @changes[:characters_skipped] << {
          name: source_character.name,
          reason: "Character with same name already exists in target campaign"
        }
        puts "  SKIP: #{source_character.name} (already exists)\n"
      else
        log_character_copy(source_character)

        unless @dry_run
          copy_template_character(source_character)
        end

        @changes[:characters_copied] << {
          name: source_character.name,
          character_type: source_character.action_values["Type"],
          archetype: source_character.action_values["Archetype"]
        }
      end
    rescue StandardError => e
      error_msg = "Error copying character #{source_character.name}: #{e.message}"
      Rails.logger.error error_msg
      @changes[:errors] << error_msg
    end
  end

  def calculate_schtick_changes(source, target)
    changes = {}

    # Compare all attributes except id, timestamps, campaign_id, prerequisite_id
    comparable_attrs = %w[name description category bonus path color archetypes]

    comparable_attrs.each do |attr|
      source_val = source.send(attr)
      target_val = target.send(attr)

      if source_val != target_val
        changes[attr] = {
          from: target_val,
          to: source_val
        }
      end
    end

    # Check image attachment
    if source.image.attached? && !target.image.attached?
      changes["image"] = {
        from: nil,
        to: "#{source.image.blob.filename} (#{source.image.blob.byte_size} bytes)"
      }
    elsif source.image.attached? && target.image.attached?
      # Check if image is different
      if source.image.blob.checksum != target.image.blob.checksum
        changes["image"] = {
          from: "#{target.image.blob.filename} (#{target.image.blob.byte_size} bytes)",
          to: "#{source.image.blob.filename} (#{source.image.blob.byte_size} bytes)"
        }
      end
    end

    changes
  end

  def calculate_weapon_changes(source, target)
    changes = {}

    # Compare all attributes except id, timestamps, campaign_id
    comparable_attrs = %w[name description damage concealment reload_value juncture mook_bonus category kachunk]

    comparable_attrs.each do |attr|
      source_val = source.send(attr)
      target_val = target.send(attr)

      if source_val != target_val
        changes[attr] = {
          from: target_val,
          to: source_val
        }
      end
    end

    # Check image attachment
    if source.image.attached? && !target.image.attached?
      changes["image"] = {
        from: nil,
        to: "#{source.image.blob.filename} (#{source.image.blob.byte_size} bytes)"
      }
    elsif source.image.attached? && target.image.attached?
      # Check if image is different
      if source.image.blob.checksum != target.image.blob.checksum
        changes["image"] = {
          from: "#{target.image.blob.filename} (#{target.image.blob.byte_size} bytes)",
          to: "#{source.image.blob.filename} (#{source.image.blob.byte_size} bytes)"
        }
      end
    end

    changes
  end

  def update_schtick(target_schtick, source_schtick, changes)
    # Update all changed attributes
    changes.except("image").each do |attr, change|
      target_schtick.send("#{attr}=", change[:to])
    end

    # Handle image update
    if changes["image"]
      attach_image(source_schtick, target_schtick, :schtick)
    end

    target_schtick.save!
    Rails.logger.info "Updated schtick: #{target_schtick.name}"
  end

  def update_weapon(target_weapon, source_weapon, changes)
    # Update all changed attributes
    changes.except("image").each do |attr, change|
      target_weapon.send("#{attr}=", change[:to])
    end

    # Handle image update
    if changes["image"]
      attach_image(source_weapon, target_weapon, :weapon)
    end

    target_weapon.save!
    Rails.logger.info "Updated weapon: #{target_weapon.name}"
  end

  def copy_template_character(source_character)
    # Use the existing CharacterDuplicatorService
    duplicated_character = CharacterDuplicatorService.duplicate_character(
      source_character,
      @target_campaign.user,
      @target_campaign
    )

    if duplicated_character.save
      CharacterDuplicatorService.apply_associations(duplicated_character)
      Rails.logger.info "Copied template character: #{duplicated_character.name}"
    else
      raise "Failed to copy character: #{duplicated_character.errors.full_messages.join(', ')}"
    end
  end

  def attach_image(source_entity, target_entity, entity_type)
    return unless source_entity.image.attached?

    begin
      # Handle ImageKit download - same logic as existing duplicator services
      downloaded = source_entity.image.blob.download

      if downloaded.class.name == 'ImageKiIo::ActiveStorage::IKFile'
        Rails.logger.info "ImageKit IKFile detected for #{entity_type} #{source_entity.name}, fetching via URL..."
        require 'net/http'
        uri = URI(downloaded.instance_variable_get(:@identifier)['url'])
        image_data = Net::HTTP.get(uri)
      elsif downloaded.is_a?(String)
        image_data = downloaded
      elsif downloaded.respond_to?(:read)
        image_data = downloaded.read
      else
        Rails.logger.warn "Unknown download object type for #{entity_type} #{source_entity.name}: #{downloaded.class}"
        return
      end

      target_entity.image.attach(
        io: StringIO.new(image_data),
        filename: source_entity.image.blob.filename,
        content_type: source_entity.image.blob.content_type
      )
    rescue => e
      Rails.logger.error "Failed to attach image for #{entity_type} #{source_entity.name}: #{e.message}"
      raise
    end
  end

  def log_schtick_update(source, target, changes)
    puts "  UPDATE: #{target.name} (ID: #{target.id})"
    changes.each do |attr, change|
      if attr == :image
        puts "    - #{attr}: #{change[:from] || 'none'} -> #{change[:to]}"
      else
        puts "    - #{attr}:"
        puts "        FROM: #{change[:from].to_s.truncate(100)}"
        puts "        TO:   #{change[:to].to_s.truncate(100)}"
      end
    end
    puts ""
  end

  def log_weapon_update(source, target, changes)
    puts "  UPDATE: #{target.name} (ID: #{target.id})"
    changes.each do |attr, change|
      if attr == :image
        puts "    - #{attr}: #{change[:from] || 'none'} -> #{change[:to]}"
      else
        puts "    - #{attr}:"
        puts "        FROM: #{change[:from].to_s.truncate(100)}"
        puts "        TO:   #{change[:to].to_s.truncate(100)}"
      end
    end
    puts ""
  end

  def log_character_copy(character)
    character_type = character.action_values["Type"]
    archetype = character.action_values["Archetype"]
    puts "  COPY: #{character.name} (#{character_type}#{archetype.present? ? " - #{archetype}" : ""})"
  end

  def print_summary
    puts "\n" + "=" * 80
    puts "SYNC SUMMARY"
    puts "=" * 80
    puts ""
    puts "Schticks:"
    puts "  - Updated: #{@changes[:schticks_updated].count}"
    puts "  - Skipped: #{@changes[:schticks_skipped].count}"
    puts ""
    puts "Weapons:"
    puts "  - Updated: #{@changes[:weapons_updated].count}"
    puts "  - Skipped: #{@changes[:weapons_skipped].count}"
    puts ""
    puts "Template Characters:"
    puts "  - Copied: #{@changes[:characters_copied].count}"
    puts "  - Skipped: #{@changes[:characters_skipped].count}"
    puts ""

    if @changes[:errors].any?
      puts "Errors: #{@changes[:errors].count}"
      @changes[:errors].each do |error|
        puts "  - #{error}"
      end
      puts ""
    end

    puts "=" * 80

    if @dry_run
      puts "\nThis was a DRY RUN - no changes were made."
      puts "To apply these changes, run with dry_run: false"
    else
      puts "\nChanges have been applied successfully!"
    end

    puts "=" * 80 + "\n"
  end
end
