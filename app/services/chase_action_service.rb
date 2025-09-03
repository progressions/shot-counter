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
    
    # Handle shot cost if provided (for the driver spending shots)
    if update[:shot_cost].present? && update[:character_id].present?
      character_shot = @fight.shots.find_by(character_id: update[:character_id])
      if character_shot
        shot_cost = update[:shot_cost].to_i
        new_shot_value = character_shot.shot - shot_cost
        Rails.logger.info "🎲 #{character_shot.character.name} spending #{shot_cost} shots for chase action (#{character_shot.shot} -> #{new_shot_value})"
        character_shot.shot = new_shot_value
        character_shot.save!
      end
    end
    
    # Handle position update if provided (directly from update, not action_values)
    if update[:position].present? && update[:target_vehicle_id].present?
      Rails.logger.info "🏎️ Updating chase position to #{update[:position]}"
      update_chase_position(vehicle, update[:target_vehicle_id], update[:position], update[:role])
    end
    
    # Update action values if provided (Chase Points, Condition Points, etc.)
    if update[:action_values].present?
      Rails.logger.info "🚗 Updating vehicle #{vehicle_name} action values: #{update[:action_values]}"
      
      # Remove Position from action_values if it exists (it's handled separately)
      update[:action_values].delete("Position")
      
      # Update the remaining vehicle's action_values (persistent)
      # Must reassign to trigger Rails change tracking for JSONB columns
      if update[:action_values].present? && update[:action_values].keys.any?
        vehicle.action_values = vehicle.action_values.merge(update[:action_values].to_h)
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