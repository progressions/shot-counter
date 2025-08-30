namespace :template do
  desc "Export master template campaign and all associations to SQL file"
  task export: :environment do
    exporter = TemplateExporter.new
    exporter.export
  end
  
  desc "Import master template from SQL file (uses most recent export or IMPORT_FILE env var)"
  task import: :environment do
    importer = TemplateImporter.new
    importer.import
  end
end

class TemplateExporter
  def initialize
    @export_dir = Rails.root.join('db', 'exports')
    @timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    @filename = "master_template_export_#{@timestamp}.sql"
    @filepath = @export_dir.join(@filename)
    @sql_statements = []
  end

  def export
    Rails.logger.info "Starting master template export..."
    
    # Find master template
    @master_template = Campaign.find_by(is_master_template: true)
    raise "No master template campaign found. Please ensure a campaign exists with is_master_template: true" unless @master_template
    
    # Ensure export directory exists
    FileUtils.mkdir_p(@export_dir)
    
    # Start transaction
    @sql_statements << "BEGIN;"
    
    # Export in dependency order
    export_campaign
    export_base_entities
    export_factions
    export_characters
    export_vehicles
    export_sites
    export_parties
    export_junctures
    export_schticks
    export_weapons
    export_join_tables
    export_image_positions
    export_active_storage_blobs_and_attachments
    
    # End transaction
    @sql_statements << "COMMIT;"
    
    # Write to file
    File.write(@filepath, @sql_statements.join("\n\n") + "\n")
    
    Rails.logger.info "Export completed: #{@filepath}"
    puts "Master template exported successfully to: #{@filepath}"
  end

  private

  def export_campaign
    Rails.logger.info "Exporting campaign: #{@master_template.name}"
    
    # For master templates, we need to include a user_id
    # We'll use a special system user or the first admin user in production
    sql = <<~SQL
      INSERT INTO campaigns (
        id, user_id, name, description, is_master_template, active,
        created_at, updated_at
      ) VALUES (
        '#{@master_template.id}',
        (SELECT id FROM users WHERE email = 'progressions@gmail.com' OR admin = true ORDER BY created_at LIMIT 1),
        #{quote(@master_template.name)},
        #{quote(@master_template.description)},
        true,
        true,
        NOW(),
        NOW()
      ) ON CONFLICT (id) DO NOTHING;
    SQL
    
    @sql_statements << sql.strip
  end

  def export_base_entities
    # Export any standalone schticks and weapons (not tied to specific characters)
    export_archetype_schticks
    export_archetype_weapons
  end

  def export_archetype_schticks
    schticks = @master_template.schticks
    return if schticks.empty?
    
    Rails.logger.info "Exporting #{schticks.count} archetype schticks"
    
    schticks.each do |schtick|
      sql = <<~SQL
        INSERT INTO schticks (
          id, campaign_id, name, description, category,
          created_at, updated_at
        ) VALUES (
          '#{schtick.id}',
          '#{@master_template.id}',
          #{quote(schtick.name)},
          #{quote(schtick.description)},
          #{quote(schtick.category)},
          NOW(),
          NOW()
        ) ON CONFLICT (id) DO NOTHING;
      SQL
      
      @sql_statements << sql.strip
    end
  end

  def export_archetype_weapons
    weapons = @master_template.weapons
    return if weapons.empty?
    
    Rails.logger.info "Exporting #{weapons.count} archetype weapons"
    
    weapons.each do |weapon|
      sql = <<~SQL
        INSERT INTO weapons (
          id, campaign_id, name, damage, concealment, reload_value,
          created_at, updated_at
        ) VALUES (
          '#{weapon.id}',
          '#{@master_template.id}',
          #{quote(weapon.name)},
          #{weapon.damage || 'NULL'},
          #{weapon.concealment || 'NULL'},
          #{weapon.reload_value || 'NULL'},
          NOW(),
          NOW()
        ) ON CONFLICT (id) DO NOTHING;
      SQL
      
      @sql_statements << sql.strip
    end
  end

  def export_factions
    factions = @master_template.factions
    return if factions.empty?
    
    Rails.logger.info "Exporting #{factions.count} factions"
    
    factions.each do |faction|
      # Include image URL as comment for reference
      image_comment = faction.image_url ? "-- Image URL: #{faction.image_url}" : "-- No image attached"
      
      sql = <<~SQL
        #{image_comment}
        INSERT INTO factions (
          id, campaign_id, name, description,
          active, created_at, updated_at
        ) VALUES (
          '#{faction.id}',
          '#{@master_template.id}',
          #{quote(faction.name)},
          #{quote(faction.description)},
          #{faction.active},
          NOW(),
          NOW()
        ) ON CONFLICT (id) DO NOTHING;
      SQL
      
      @sql_statements << sql.strip
    end
  end

  def export_characters
    characters = @master_template.characters
    return if characters.empty?
    
    Rails.logger.info "Exporting #{characters.count} characters"
    
    characters.each do |character|
      # Include image URL as comment for reference
      image_comment = character.image_url ? "-- Image URL: #{character.image_url}" : "-- No image attached"
      
      sql = <<~SQL
        #{image_comment}
        INSERT INTO characters (
          id, campaign_id, name, description,
          action_values, skills, active,
          faction_id, created_at, updated_at
        ) VALUES (
          '#{character.id}',
          '#{@master_template.id}',
          #{quote(character.name)},
          #{quote(character.description.to_json)},
          #{quote(character.action_values.to_json)},
          #{quote(character.skills.to_json)},
          #{character.active},
          #{character.faction_id ? "'#{character.faction_id}'" : 'NULL'},
          NOW(),
          NOW()
        ) ON CONFLICT (id) DO NOTHING;
      SQL
      
      @sql_statements << sql.strip
    end
  end

  def export_vehicles
    vehicles = @master_template.vehicles
    return if vehicles.empty?
    
    Rails.logger.info "Exporting #{vehicles.count} vehicles"
    
    vehicles.each do |vehicle|
      # Include image URL as comment for reference
      image_comment = vehicle.image_url ? "-- Image URL: #{vehicle.image_url}" : "-- No image attached"
      
      sql = <<~SQL
        #{image_comment}
        INSERT INTO vehicles (
          id, campaign_id, name, action_values,
          active, faction_id,
          created_at, updated_at
        ) VALUES (
          '#{vehicle.id}',
          '#{@master_template.id}',
          #{quote(vehicle.name)},
          #{quote(vehicle.action_values.to_json)},
          #{vehicle.active},
          #{vehicle.faction_id ? "'#{vehicle.faction_id}'" : 'NULL'},
          NOW(),
          NOW()
        ) ON CONFLICT (id) DO NOTHING;
      SQL
      
      @sql_statements << sql.strip
    end
  end

  def export_sites
    sites = @master_template.sites
    return if sites.empty?
    
    Rails.logger.info "Exporting #{sites.count} sites"
    
    sites.each do |site|
      sql = <<~SQL
        INSERT INTO sites (
          id, campaign_id, name, description, active,
          faction_id, juncture_id,
          created_at, updated_at
        ) VALUES (
          '#{site.id}',
          '#{@master_template.id}',
          #{quote(site.name)},
          #{quote(site.description)},
          #{site.active},
          #{site.faction_id ? "'#{site.faction_id}'" : 'NULL'},
          #{site.juncture_id ? "'#{site.juncture_id}'" : 'NULL'},
          NOW(),
          NOW()
        ) ON CONFLICT (id) DO NOTHING;
      SQL
      
      @sql_statements << sql.strip
    end
  end

  def export_parties
    parties = @master_template.parties
    return if parties.empty?
    
    Rails.logger.info "Exporting #{parties.count} parties"
    
    parties.each do |party|
      sql = <<~SQL
        INSERT INTO parties (
          id, campaign_id, name, description,
          created_at, updated_at
        ) VALUES (
          '#{party.id}',
          '#{@master_template.id}',
          #{quote(party.name)},
          #{quote(party.description)},
          NOW(),
          NOW()
        ) ON CONFLICT (id) DO NOTHING;
      SQL
      
      @sql_statements << sql.strip
    end
  end

  def export_junctures
    junctures = @master_template.junctures
    return if junctures.empty?
    
    Rails.logger.info "Exporting #{junctures.count} junctures"
    
    junctures.each do |juncture|
      sql = <<~SQL
        INSERT INTO junctures (
          id, campaign_id, faction_id, name, description,
          active, created_at, updated_at
        ) VALUES (
          '#{juncture.id}',
          '#{@master_template.id}',
          #{juncture.faction_id ? "'#{juncture.faction_id}'" : 'NULL'},
          #{quote(juncture.name)},
          #{quote(juncture.description)},
          #{juncture.active},
          NOW(),
          NOW()
        ) ON CONFLICT (id) DO NOTHING;
      SQL
      
      @sql_statements << sql.strip
    end
  end

  def export_schticks
    # Schticks are already exported in export_archetype_schticks
    return
  end

  def export_weapons
    # Weapons are already exported in export_archetype_weapons
    return
  end

  def export_join_tables
    export_character_schticks
    export_carries
    # Note: memberships are for party-character relationships, not exported here
  end

  def export_character_schticks
    character_schticks = CharacterSchtick.joins(:character).where(characters: { campaign_id: @master_template.id })
    return if character_schticks.empty?
    
    Rails.logger.info "Exporting #{character_schticks.count} character_schticks associations"
    
    character_schticks.each do |cs|
      sql = <<~SQL
        INSERT INTO character_schticks (
          character_id, schtick_id,
          created_at, updated_at
        ) VALUES (
          '#{cs.character_id}',
          '#{cs.schtick_id}',
          NOW(),
          NOW()
        ) ON CONFLICT (character_id, schtick_id) DO NOTHING;
      SQL
      
      @sql_statements << sql.strip
    end
  end

  def export_carries
    carries = Carry.joins(:character).where(characters: { campaign_id: @master_template.id })
    return if carries.empty?
    
    Rails.logger.info "Exporting #{carries.count} carries associations"
    
    carries.each do |carry|
      sql = <<~SQL
        INSERT INTO carries (
          id, character_id, weapon_id,
          created_at, updated_at
        ) VALUES (
          '#{carry.id}',
          '#{carry.character_id}',
          '#{carry.weapon_id}',
          NOW(),
          NOW()
        ) ON CONFLICT (id) DO NOTHING;
      SQL
      
      @sql_statements << sql.strip
    end
  end

  # Memberships are for party-character relationships, not character-faction

  def export_active_storage_blobs_and_attachments
    # Get all Active Storage attachments for entities in this campaign
    # Build a hash of entity types to their IDs
    entities_by_type = {
      'Campaign' => [@master_template.id],
      'Character' => @master_template.characters.pluck(:id),
      'Vehicle' => @master_template.vehicles.pluck(:id),
      'Faction' => @master_template.factions.pluck(:id),
      'Site' => @master_template.sites.pluck(:id),
      'Juncture' => @master_template.junctures.pluck(:id),
      'Party' => @master_template.parties.pluck(:id),
      'Schtick' => @master_template.schticks.pluck(:id),
      'Weapon' => @master_template.weapons.pluck(:id)
    }
    
    # Build WHERE conditions for each entity type
    conditions = entities_by_type.map do |type, ids|
      next if ids.empty?
      "(record_type = '#{type}' AND record_id IN (#{ids.map { |id| "'#{id}'" }.join(',')}))"
    end.compact
    
    return if conditions.empty?
    
    # Get all attachments for all entity types
    attachments = ActiveStorage::Attachment.where(conditions.join(' OR ')).where(name: 'image')
    
    return if attachments.empty?
    
    Rails.logger.info "Exporting #{attachments.count} active storage attachments with blobs"
    
    # First, export the blobs
    blob_ids = attachments.pluck(:blob_id).uniq
    blobs = ActiveStorage::Blob.where(id: blob_ids)
    
    Rails.logger.info "Exporting #{blobs.count} active storage blobs"
    
    blobs.each do |blob|
      sql = <<~SQL
        INSERT INTO active_storage_blobs (
          id, key, filename, content_type, metadata, 
          service_name, byte_size, checksum, created_at
        ) VALUES (
          '#{blob.id}',
          #{quote(blob.key)},
          #{quote(blob.filename.to_s)},
          #{quote(blob.content_type)},
          #{quote(blob.metadata.to_json)},
          #{quote(blob.service_name)},
          #{blob.byte_size},
          #{quote(blob.checksum)},
          NOW()
        ) ON CONFLICT (id) DO NOTHING;
      SQL
      
      @sql_statements << sql.strip
    end
    
    # Then export the attachments
    attachments.each do |attachment|
      sql = <<~SQL
        INSERT INTO active_storage_attachments (
          id, name, record_type, record_id, blob_id,
          created_at
        ) VALUES (
          '#{attachment.id}',
          #{quote(attachment.name)},
          #{quote(attachment.record_type)},
          '#{attachment.record_id}',
          '#{attachment.blob_id}',
          NOW()
        ) ON CONFLICT (id) DO NOTHING;
      SQL
      
      @sql_statements << sql.strip
    end
  end

  def export_image_positions
    # Get all image positions for entities in this campaign
    entity_types = []
    
    # Collect all entity IDs and types
    @master_template.characters.pluck(:id).each do |id|
      entity_types << ['Character', id]
    end
    
    @master_template.vehicles.pluck(:id).each do |id|
      entity_types << ['Vehicle', id]
    end
    
    @master_template.factions.pluck(:id).each do |id|
      entity_types << ['Faction', id]
    end
    
    @master_template.sites.pluck(:id).each do |id|
      entity_types << ['Site', id]
    end
    
    @master_template.junctures.pluck(:id).each do |id|
      entity_types << ['Juncture', id]
    end
    
    @master_template.parties.pluck(:id).each do |id|
      entity_types << ['Party', id]
    end
    
    @master_template.schticks.pluck(:id).each do |id|
      entity_types << ['Schtick', id]
    end
    
    @master_template.weapons.pluck(:id).each do |id|
      entity_types << ['Weapon', id]
    end
    
    # Include campaign itself
    entity_types << ['Campaign', @master_template.id]
    
    return if entity_types.empty?
    
    # Query for image positions
    image_positions = ImagePosition.where(
      entity_types.map { |type, id| "(positionable_type = '#{type}' AND positionable_id = '#{id}')" }.join(" OR ")
    )
    
    return if image_positions.empty?
    
    Rails.logger.info "Exporting #{image_positions.count} image positions"
    
    image_positions.each do |position|
      sql = <<~SQL
        INSERT INTO image_positions (
          id, positionable_type, positionable_id, context,
          x_position, y_position, style_overrides,
          created_at, updated_at
        ) VALUES (
          '#{position.id}',
          #{quote(position.positionable_type)},
          '#{position.positionable_id}',
          #{quote(position.context)},
          #{position.x_position},
          #{position.y_position},
          #{quote(position.style_overrides.to_json)},
          NOW(),
          NOW()
        ) ON CONFLICT (id) DO NOTHING;
      SQL
      
      @sql_statements << sql.strip
    end
  end

  def quote(value)
    return 'NULL' if value.nil?
    "'#{value.to_s.gsub("'", "''")}'"
  end
end

class TemplateImporter
  def initialize
    @export_dir = Rails.root.join('db', 'exports')
  end
  
  def import
    Rails.logger.info "Starting master template import..."
    
    # Find the import file
    import_file = find_import_file
    raise "Import file not found: #{ENV['IMPORT_FILE']}" if ENV['IMPORT_FILE'] && !File.exist?(import_file)
    
    # Ensure required user exists
    ensure_admin_user_exists
    
    # Read the SQL content
    sql_content = File.read(import_file)
    Rails.logger.info "Importing from: #{import_file}"
    
    # Execute the SQL (already contains BEGIN/COMMIT)
    begin
      ActiveRecord::Base.connection.execute(sql_content)
      Rails.logger.info "Import completed successfully"
      # Reset connection state after executing raw SQL with transactions
      ActiveRecord::Base.connection.reconnect!
    rescue => e
      Rails.logger.error "Import failed: #{e.message}"
      ActiveRecord::Base.connection.reconnect!
      raise
    end
    
    # Log summary
    master_template = Campaign.find_by(is_master_template: true)
    if master_template
      Rails.logger.info "Master template '#{master_template.name}' imported with:"
      Rails.logger.info "  - #{master_template.characters.count} characters"
      Rails.logger.info "  - #{master_template.vehicles.count} vehicles"
      Rails.logger.info "  - #{master_template.factions.count} factions"
      Rails.logger.info "  - #{master_template.sites.count} sites"
      Rails.logger.info "  - #{master_template.schticks.count} schticks"
      Rails.logger.info "  - #{master_template.weapons.count} weapons"
    end
    
    puts "Template import completed successfully from: #{File.basename(import_file)}"
  end
  
  private
  
  def find_import_file
    if ENV['IMPORT_FILE']
      # Use specified file
      Pathname.new(ENV['IMPORT_FILE'])
    else
      # Find most recent export
      export_files = Dir[@export_dir.join('*.sql')].sort
      raise "No export files found in #{@export_dir}. Run 'rake template:export' first." if export_files.empty?
      
      Pathname.new(export_files.last)
    end
  end
  
  def ensure_admin_user_exists
    # Ensure there's an admin user for the campaign assignment
    unless User.exists?(email: 'progressions@gmail.com') || User.exists?(admin: true)
      Rails.logger.warn "No admin user found. Creating default admin user."
      User.create!(
        email: 'progressions@gmail.com',
        password: SecureRandom.hex(16),
        first_name: 'System',
        last_name: 'Admin',
        admin: true,
        confirmed_at: Time.now
      )
    end
  end
end