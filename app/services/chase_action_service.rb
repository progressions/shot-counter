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
    
    # Update action values if provided (Position, Chase Points, Condition Points, etc.)
    if update[:action_values].present?
      Rails.logger.info "🚗 Updating vehicle #{vehicle_name} action values: #{update[:action_values]}"
      
      # Update the vehicle's action_values (persistent)
      # Must reassign to trigger Rails change tracking for JSONB columns
      vehicle.action_values = vehicle.action_values.merge(update[:action_values])
      vehicle.save!
      
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
end