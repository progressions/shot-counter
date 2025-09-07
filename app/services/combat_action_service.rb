class CombatActionService
  def self.apply_combat_action(fight, character_updates)
    new(fight, character_updates).apply
  end

  def initialize(fight, character_updates)
    @fight = fight
    @character_updates = character_updates
  end

  def apply
    result = nil

    ActiveRecord::Base.transaction do
      # Disable individual broadcasts during the transaction
      Thread.current[:disable_broadcasts] = true

      begin
        @character_updates.each do |update|
          apply_character_update(update)
        end

        # Touch the fight to update its timestamp
        @fight.touch

        # Store the result for returning after transaction
        result = @fight
      ensure
        # Re-enable broadcasts
        Thread.current[:disable_broadcasts] = false
      end
    end

    # Manually trigger the encounter broadcast since it was disabled during the transaction
    @fight.broadcast_encounter_update!

    Rails.logger.info "🔄 BATCHED WEBSOCKET: Completed #{@character_updates.length} character updates for fight #{@fight.id}"

    result
  end

  private

  def apply_character_update(update)
    # Find the shot record for this character/vehicle
    shot = if update[:shot_id].present?
      found_shot = @fight.shots.find(update[:shot_id])
      # If character_id is also provided, validate it matches
      if update[:character_id].present? && found_shot.character_id != update[:character_id]
        raise ActiveRecord::RecordNotFound, "Character ID does not match shot's character"
      end
      found_shot
    elsif update[:character_id].present?
      @fight.shots.find_by!(character_id: update[:character_id])
    elsif update[:vehicle_id].present?
      @fight.shots.find_by!(vehicle_id: update[:vehicle_id])
    else
      raise ArgumentError, "Must provide shot_id, character_id, or vehicle_id"
    end

    entity = shot.character || shot.vehicle
    entity_name = entity&.name || "Unknown"

    # Update shot position if provided
    if update[:shot].present? && shot.shot != update[:shot]
      Rails.logger.info "🎯 Moving #{entity_name} from shot #{shot.shot} to #{update[:shot]}"
      shot.shot = update[:shot]
      shot.save!
    end

    # For PCs, update the character record (persistent across fights)
    # Only PCs maintain persistent character records with wounds in action_values
    character_type = shot.character&.action_values&.fetch("Type", nil)
    if character_type == "PC"
      character = shot.character

      # Track wounds before update for threshold checking
      old_wounds = character.action_values["Wounds"] || 0

      # Update action values if provided (includes Wounds, Fortune, etc.)
      if update[:action_values].present?
        Rails.logger.info "📊 Updating PC #{character.name} action values: #{update[:action_values]}"
        Rails.logger.info "📊 Current action_values before merge: #{character.action_values.inspect}"
        # Must reassign to trigger Rails change tracking for JSONB columns
        character.action_values = character.action_values.merge(update[:action_values])
        Rails.logger.info "📊 New action_values after merge: #{character.action_values.inspect}"
        Rails.logger.info "📊 Character changed?: #{character.changed?}"
        Rails.logger.info "📊 Character changes: #{character.changes.inspect}"
      end

      # Check for Up Check threshold crossing (PC/Ally only - already filtered above)
      new_wounds = character.action_values["Wounds"] || 0
      wound_threshold = 35  # Standard threshold for PC/Ally (Boss would be 50 but they're NPCs)

      # Check if crossing threshold from below to at/above
      if new_wounds >= wound_threshold
        Rails.logger.info "⚠️ #{character.name} crossed wound threshold (#{old_wounds} -> #{new_wounds}), triggering Up Check"

        # Set up_check_required status
        character.add_status("up_check_required")

        # Increment Marks of Death
        marks = character.action_values["Marks of Death"] || 0
        character.action_values = character.action_values.merge("Marks of Death" => marks + 1)

        # Create fight event
        @fight.fight_events.create!(
          event_type: "wound_threshold",
          description: "#{character.name} reached wound threshold and needs an Up Check",
          details: {
            character_id: character.id,
            wounds: new_wounds,
            threshold: wound_threshold,
            marks_of_death: marks + 1
          }
        )
      elsif old_wounds >= wound_threshold && new_wounds < wound_threshold && character.up_check_required?
        # Healed below threshold, clear up_check_required status
        Rails.logger.info "💚 #{character.name} healed below wound threshold (#{old_wounds} -> #{new_wounds}), clearing Up Check requirement"
        character.remove_status("up_check_required")
      end

      # Update impairments if provided
      if update[:impairments].present?
        Rails.logger.info "🤕 Updating PC #{character.name} impairments to #{update[:impairments]}"
        character.impairments = update[:impairments]
      end

      # Update defense if provided
      if update[:defense].present?
        Rails.logger.info "🛡️ Updating PC #{character.name} defense to #{update[:defense]}"
        character.action_values["Defense"] = update[:defense]
      end

      # Update any other character attributes
      if update[:attributes].present?
        update[:attributes].each do |key, value|
          if character.respond_to?("#{key}=")
            Rails.logger.info "✏️ Updating PC #{character.name} #{key} to #{value}"
            character.send("#{key}=", value)
          end
        end
      end

      # Handle status updates - remove first, then add
      if update[:remove_status].present?
        update[:remove_status].each do |status|
          Rails.logger.info "➖ Removing status '#{status}' from PC #{character.name}"
          character.remove_status(status)
        end
      end

      if update[:add_status].present?
        update[:add_status].each do |status|
          Rails.logger.info "➕ Adding status '#{status}' to PC #{character.name}"
          Rails.logger.info "📊 Current status before add: #{character.status.inspect}"
          character.add_status(status)
          Rails.logger.info "📊 Status after add: #{character.status.inspect}"
        end
      end

      # Always save if we had any updates for this character
      should_save = update[:action_values].present? ||
                    update[:impairments].present? ||
                    update[:defense].present? ||
                    update[:attributes].present? ||
                    update[:remove_status].present? ||
                    update[:add_status].present? ||
                    character.changed?

      Rails.logger.info "📊 Should save?: #{should_save}"
      Rails.logger.info "📊 Character before save - Wounds: #{character.action_values['Wounds']}, Status: #{character.status.inspect}"

      if should_save
        Rails.logger.info "📊 Saving character #{character.name}..."
        character.save!
        character.reload
        Rails.logger.info "📊 Character saved! Wounds after save: #{character.action_values['Wounds']}, Status: #{character.status.inspect}"
      else
        Rails.logger.info "📊 Not saving character - no changes detected"
      end
    else
      # For NPCs, Vehicles, and Mooks, update the shot record (fight-specific)

      # Store old wounds for threshold checking
      old_wounds = shot.count || 0

      # Update wounds/count on the shot
      if update[:wounds].present? || update[:count].present?
        new_value = update[:count] || update[:wounds] || 0
        Rails.logger.info "💔 Updating NPC/Vehicle #{entity_name} wounds/count to #{new_value}"
        shot.count = new_value
      end

      # Check for out_of_fight status for NPCs based on wound thresholds
      if entity.is_a?(Character)
        new_wounds = shot.count || 0

        # Determine wound threshold based on character type
        char_type = entity.action_values["Type"]
        wound_threshold = case char_type
        when "Uber-Boss", "Boss"
          50
        when "Featured Foe"
          25
        when "Ally"
          35
        when "PC"
          35
        when "Mook"
          0  # Mooks are out when count reaches 0
        else
          nil
        end

        if wound_threshold
          # For mooks, check if count is 0
          if char_type == "Mook"
            if new_wounds <= 0 && !entity.status&.include?("out_of_fight")
              Rails.logger.info "💀 Mooks #{entity.name} eliminated (count: #{new_wounds})"
              entity.add_status("out_of_fight")
              entity.save!

              @fight.fight_events.create!(
                event_type: "out_of_fight",
                description: "#{entity.name} eliminated!",
                details: {
                  character_id: entity.id,
                  wounds: new_wounds,
                  character_type: char_type
                }
              )
            elsif new_wounds > 0 && entity.status&.include?("out_of_fight")
              # Revived/reinforced
              entity.remove_status("out_of_fight")
              entity.save!
            end
          else
            # For non-mooks: simple rule - if wounds >= threshold, they're out
            if new_wounds >= wound_threshold
              # Boss and Uber-Boss get up_check_required instead of out_of_fight
              if char_type == "Boss" || char_type == "Uber-Boss"
                if !entity.status&.include?("up_check_required")
                  Rails.logger.info "⚠️ #{entity.name} needs an Up Check! (#{new_wounds} wounds >= #{wound_threshold} threshold)"
                  entity.add_status("up_check_required")
                  entity.save!

                  # Create event for Up Check needed
                  @fight.fight_events.create!(
                    event_type: "wound_threshold",
                    description: "#{entity.name} needs an Up Check!",
                    details: {
                      character_id: entity.id,
                      wounds: new_wounds,
                      threshold: wound_threshold,
                      character_type: char_type
                    }
                  )
                end
              else
                # Non-Boss characters go straight to out_of_fight
                if !entity.status&.include?("out_of_fight")
                  Rails.logger.info "💀 #{entity.name} is out of the fight! (#{new_wounds} wounds >= #{wound_threshold} threshold)"
                  entity.add_status("out_of_fight")
                  entity.save!

                  # Create event when going out
                  @fight.fight_events.create!(
                    event_type: "out_of_fight",
                    description: "#{entity.name} is out of the fight!",
                    details: {
                      character_id: entity.id,
                      wounds: new_wounds,
                      threshold: wound_threshold,
                      character_type: char_type
                    }
                  )
                end
              end
            else
              # wounds < threshold, so they should be in the fight
              if entity.status&.include?("out_of_fight")
                Rails.logger.info "💚 #{entity.name} is back in the fight! (#{new_wounds} wounds < #{wound_threshold} threshold)"
                entity.remove_status("out_of_fight")
                entity.save!
              elsif entity.status&.include?("up_check_required")
                Rails.logger.info "💚 #{entity.name} healed below threshold, clearing Up Check requirement (#{new_wounds} wounds < #{wound_threshold} threshold)"
                entity.remove_status("up_check_required")
                entity.save!
              end
            end
          end
        end
      end

      # Update impairments on the shot
      if update[:impairments].present?
        Rails.logger.info "🤕 Updating NPC/Vehicle #{entity_name} impairments to #{update[:impairments]}"
        shot.impairments = update[:impairments]
      end

      # Handle status updates for NPCs/Vehicles - remove first, then add
      if update[:remove_status].present? && entity.is_a?(Character)
        update[:remove_status].each do |status|
          Rails.logger.info "➖ Removing status '#{status}' from #{entity_name}"
          entity.remove_status(status)
        end
      end

      if update[:add_status].present? && entity.is_a?(Character)
        update[:add_status].each do |status|
          Rails.logger.info "➕ Adding status '#{status}' to #{entity_name}"
          entity.add_status(status)
        end
      end

      # Save if shot or entity changed
      shot.save! if shot.changed?
      entity.save! if entity.is_a?(Character) && entity.changed?
    end

    # Log the combat event if provided
    if update[:event].present?
      Rails.logger.info "📝 Creating fight event: #{update[:event][:description]}"
      @fight.fight_events.create!(
        event_type: update[:event][:type] || "combat",
        description: update[:event][:description] || "Combat action",
        details: update[:event][:details] || {}
      )
    end
  end
end
