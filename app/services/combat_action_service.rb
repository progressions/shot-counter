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
    if shot.character&.is_pc?
      character = shot.character
      
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
      
      # Update impairments if provided
      if update[:impairments].present?
        Rails.logger.info "🤕 Updating PC #{character.name} impairments to #{update[:impairments]}"
        character.impairments = update[:impairments]
      end
      
      # Update defense if provided
      if update[:defense].present?
        Rails.logger.info "🛡️ Updating PC #{character.name} defense to #{update[:defense]}"
        character.defense = update[:defense]
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
      
      # Always save if we had any updates for this character
      should_save = update[:action_values].present? || 
                    update[:impairments].present? || 
                    update[:defense].present? || 
                    update[:attributes].present? ||
                    character.changed?
      
      Rails.logger.info "📊 Should save?: #{should_save}"
      Rails.logger.info "📊 Character before save - Wounds: #{character.action_values['Wounds']}"
      
      if should_save
        character.save!
        character.reload
        Rails.logger.info "📊 Character saved! Wounds after save: #{character.action_values['Wounds']}"
      end
    else
      # For NPCs, Vehicles, and Mooks, update the shot record (fight-specific)
      
      # Update wounds/count on the shot
      if update[:wounds].present? || update[:count].present?
        new_value = update[:count] || update[:wounds] || 0
        Rails.logger.info "💔 Updating NPC/Vehicle #{entity_name} wounds/count to #{new_value}"
        shot.count = new_value
      end
      
      # Update impairments on the shot
      if update[:impairments].present?
        Rails.logger.info "🤕 Updating NPC/Vehicle #{entity_name} impairments to #{update[:impairments]}"
        shot.impairments = update[:impairments]
      end
      
      # Update defense on the shot
      if update[:defense].present?
        Rails.logger.info "🛡️ Updating NPC/Vehicle #{entity_name} defense to #{update[:defense]}"
        shot.defense = update[:defense]
      end
      
      shot.save! if shot.changed?
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
