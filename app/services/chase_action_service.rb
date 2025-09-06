class ChaseActionService
  def self.apply_chase_action(fight, vehicle_updates)
    new(fight, vehicle_updates).apply
  end

  def initialize(fight, vehicle_updates)
    @fight = fight
    @vehicle_updates = vehicle_updates
  end

  def apply
    result = nil
    
    ActiveRecord::Base.transaction do
      # Disable individual broadcasts during the transaction
      Thread.current[:disable_broadcasts] = true
      
      begin
        @vehicle_updates.each do |update|
          apply_vehicle_update(update)
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
    
    Rails.logger.info "🏎️ CHASE ACTION: Completed #{@vehicle_updates.length} vehicle updates for fight #{@fight.id}"
    
    result
  end

  private

  def apply_vehicle_update(update)
    # Find the vehicle
    vehicle = Vehicle.find(update[:vehicle_id])
    
    # Find the shot record for this vehicle
    shot = @fight.shots.find_by!(vehicle_id: vehicle.id)
    vehicle_name = vehicle.name || "Unknown Vehicle"
    
    # Track if vehicle was already defeated before this update
    was_defeated_before = vehicle.defeated_in_chase?(shot)
    
    Rails.logger.info "🎯 Chase update received - shot_cost: #{update[:shot_cost].inspect}, character_id: #{update[:character_id].inspect}"
    
    # Handle shot cost if provided (for the driver spending shots)
    if update[:shot_cost].present? && update[:character_id].present?
      character_shot = @fight.shots.find_by(character_id: update[:character_id])
      if character_shot
        shot_cost = update[:shot_cost].to_i
        # Ensure we don't go below -10 (the minimum allowed shot value)
        new_shot_value = [character_shot.shot - shot_cost, -10].max
        actual_cost = character_shot.shot - new_shot_value
        Rails.logger.info "🎲 #{character_shot.character.name} spending #{actual_cost} shots for chase action (#{character_shot.shot} -> #{new_shot_value})"
        character_shot.shot = new_shot_value
        character_shot.save!
      else
        Rails.logger.warn "⚠️ Could not find shot record for character #{update[:character_id]} in fight #{@fight.id}"
      end
    elsif update[:shot_cost].present?
      Rails.logger.warn "⚠️ Shot cost provided (#{update[:shot_cost]}) but no character_id"
    end
    
    # Handle Fortune spending if provided
    if update[:fortune_spent].present? && update[:fortune_spent] > 0 && update[:character_id].present?
      character = Character.find(update[:character_id])
      current_fortune = character.action_values["Fortune"] || 0
      if current_fortune > 0
        fortune_to_spend = [update[:fortune_spent].to_i, current_fortune].min
        new_fortune = current_fortune - fortune_to_spend
        
        Rails.logger.info "⭐ #{character.name} spending #{fortune_to_spend} Fortune point(s) for chase action (#{current_fortune} -> #{new_fortune})"
        
        # Update character's Fortune value
        updated_values = character.action_values.dup
        updated_values["Fortune"] = new_fortune
        character.action_values = updated_values
        character.save!
      end
    end
    
    # Handle Fortune spending if provided
    if update[:fortune_spent].present? && update[:fortune_spent] > 0 && update[:character_id].present?
      character = Character.find(update[:character_id])
      current_fortune = character.action_values["Fortune"] || 0
      if current_fortune > 0
        fortune_to_spend = [update[:fortune_spent].to_i, current_fortune].min
        new_fortune = current_fortune - fortune_to_spend
        
        Rails.logger.info "⭐ #{character.name} spending #{fortune_to_spend} Fortune point(s) for chase action (#{current_fortune} -> #{new_fortune})"
        
        # Update character's Fortune value
        updated_values = character.action_values.dup
        updated_values["Fortune"] = new_fortune
        character.action_values = updated_values
        character.save!
      end
    end
    
    # Handle position update if provided (directly from update, not action_values)
    if update[:position].present? && update[:target_vehicle_id].present?
      Rails.logger.info "🏎️ Updating chase position to #{update[:position]}"
      update_chase_position(vehicle, update[:target_vehicle_id], update[:position], update[:role])
    end
    
    # Check if this is a ram, sideswipe, or weapon attack
    if update[:action_type].present?
      action_type = update[:action_type].to_s.downcase
      if ["ram", "sideswipe", "weapon"].include?(action_type)
        Rails.logger.info "🚗💥 Vehicle #{vehicle_name} was #{action_type}ed - marking as damaged"
        shot.was_rammed_or_damaged = true
        shot.save!
      end
    end
    
    # Update action values if provided (Chase Points, Condition Points, etc.)
    if update[:action_values].present?
      Rails.logger.info "🚗 Updating vehicle #{vehicle_name} action values: #{update[:action_values]}"
      
      # Remove Position from action_values if it exists (it's handled separately)
      update[:action_values].delete("Position")
      
      # Update the remaining vehicle's action_values (persistent)
      # Must reassign to trigger Rails change tracking for JSONB columns
      if update[:action_values].present? && update[:action_values].keys.any?
        updated_values = vehicle.action_values.dup
        
        # For Chase Points and Condition Points, ADD to existing values instead of replacing
        ["Chase Points", "Condition Points"].each do |damage_type|
          if update[:action_values][damage_type].present?
            current_value = vehicle.action_values[damage_type] || 0
            damage_to_add = update[:action_values][damage_type].to_i
            updated_values[damage_type] = current_value + damage_to_add
            Rails.logger.info "🎯 #{damage_type}: Adding #{damage_to_add} to current #{current_value} = #{updated_values[damage_type]}"
          end
        end
        
        # For other values, merge normally (replace)
        update[:action_values].except("Chase Points", "Condition Points").each do |key, value|
          updated_values[key] = value
        end
        
        vehicle.action_values = updated_values
        vehicle.save!
      end
      
      Rails.logger.info "🚗 Vehicle #{vehicle_name} saved with new action values"
    end
    
    # Log the chase event if provided
    if update[:event].present?
      Rails.logger.info "📝 Creating fight event: #{update[:event][:description]}"
      @fight.fight_events.create!(
        event_type: update[:event][:type] || "chase",
        description: update[:event][:description] || "Chase action",
        details: update[:event][:details] || {}
      )
    end
    
    # Check if vehicle was defeated in this update
    if !was_defeated_before && vehicle.defeated_in_chase?(shot)
      defeat_message = if vehicle.defeat_type(shot) == "crashed"
        "#{vehicle_name} has crashed!"
      else
        "#{vehicle_name} is boxed in!"
      end
      
      Rails.logger.info "🚗💥 DEFEAT: #{defeat_message}"
      
      # Create fight event for defeat
      @fight.fight_events.create!(
        event_type: "chase_defeat",
        description: defeat_message,
        details: {
          vehicle_id: vehicle.id,
          vehicle_name: vehicle_name,
          defeat_type: vehicle.defeat_type(shot),
          chase_points: vehicle.action_values["Chase Points"],
          was_rammed_or_damaged: shot.was_rammed_or_damaged
        }
      )
    end
  end

  def update_chase_position(vehicle, target_vehicle_id, new_position, role = nil)
    target_vehicle = Vehicle.find(target_vehicle_id)
    
    # Find or create relationship between the vehicles
    relationship = find_or_create_chase_relationship(vehicle, target_vehicle, role)
    
    Rails.logger.info "🏎️ Updating chase position between #{vehicle.name} and #{target_vehicle.name} to #{new_position}"
    relationship.update!(position: new_position)
  end
  
  def find_or_create_chase_relationship(vehicle1, vehicle2, vehicle1_role = nil)
    # Check if relationship already exists (in either direction)
    existing = ChaseRelationship.active.find_by(
      pursuer: vehicle1, 
      evader: vehicle2, 
      fight: @fight
    ) || ChaseRelationship.active.find_by(
      pursuer: vehicle2,
      evader: vehicle1,
      fight: @fight
    )
    
    return existing if existing
    
    # Create new relationship based on role
    # If no role specified, default to vehicle1 as pursuer
    if vehicle1_role == "evader"
      Rails.logger.info "🎯 Creating new chase relationship: #{vehicle2.name} (pursuer) chasing #{vehicle1.name} (evader)"
      ChaseRelationship.create!(
        pursuer: vehicle2,
        evader: vehicle1,
        fight: @fight,
        position: "far" # Default starting position
      )
    else # Default to vehicle1 as pursuer
      Rails.logger.info "🎯 Creating new chase relationship: #{vehicle1.name} (pursuer) chasing #{vehicle2.name} (evader)"
      ChaseRelationship.create!(
        pursuer: vehicle1,
        evader: vehicle2,
        fight: @fight,
        position: "far" # Default starting position
      )
    end
  end
end