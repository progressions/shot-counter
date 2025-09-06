class UpCheckService
  UP_CHECK_THRESHOLD = 5

  def self.apply_up_check(fight:, character_id:, swerve:, fortune: 0)
    new(fight: fight, character_id: character_id, swerve: swerve, fortune: fortune).apply
  end

  def initialize(fight:, character_id:, swerve:, fortune: 0)
    @fight = fight
    @character_id = character_id
    @swerve = swerve.to_i
    @fortune = fortune.to_i
  end

  def apply
    result = nil
    
    ActiveRecord::Base.transaction do
      # Disable individual broadcasts during the transaction
      Thread.current[:disable_broadcasts] = true
      
      begin
        # Find the character's shot in this fight
        @shot = @fight.shots.find_by!(character_id: @character_id)
        @character = @shot.character
        
        # Validate character can make Up Check
        validate_up_check_eligibility!
        
        character_type = @character.action_values["Type"]
        is_boss_type = ["Boss", "Uber-Boss"].include?(character_type)
        
        if is_boss_type
          # Boss/Uber-Boss Up Check: Frontend sends 1 for pass, 0 for fail
          passed = @swerve == 1  # Frontend sends 1 for pass, 0 for fail
          
          Rails.logger.info "🎲 BOSS UP CHECK: #{@character.name} - #{passed ? 'PASSED' : 'FAILED'}"
          
          # Update character status based on result
          if passed
            @character.remove_status("up_check_required")
            Rails.logger.info "✅ BOSS UP CHECK SUCCESS: #{@character.name} stays in the fight"
          else
            @character.remove_status("up_check_required")
            @character.add_status("out_of_fight")
            Rails.logger.info "❌ BOSS UP CHECK FAILED: #{@character.name} is out of the fight"
          end
          
          fortune_used = false
          total = @swerve  # Just for logging, 1 or 0
          toughness = 0
        else
          # PC/Ally Up Check: Toughness + Swerve + Fortune vs 5
          # Handle Fortune die usage
          fortune_used = handle_fortune_usage!
          
          # Always increment Marks of Death for making the check
          increment_marks_of_death!
          
          # Calculate the check result
          toughness = @character.action_values["Toughness"] || 0
          total = @swerve + @fortune + toughness
          passed = total >= UP_CHECK_THRESHOLD
          
          Rails.logger.info "🎲 UP CHECK: #{@character.name} rolled #{@swerve} + #{@fortune} (Fortune) + #{toughness} (Toughness) = #{total} vs #{UP_CHECK_THRESHOLD}"
          
          # Update character status based on result
          if passed
            @character.remove_status("up_check_required")
            Rails.logger.info "✅ UP CHECK SUCCESS: #{@character.name} stays in the fight"
          else
            @character.remove_status("up_check_required")
            @character.add_status("out_of_fight")
            Rails.logger.info "❌ UP CHECK FAILED: #{@character.name} is out of the fight"
          end
        end
        
        # Create fight event
        if is_boss_type
          @fight.fight_events.create!(
            event_type: "up_check",
            description: "#{@character.name} #{passed ? 'passed' : 'failed'} the Boss Up Check and #{passed ? 'stays in the fight' : 'is out of the fight'}",
            details: {
              character_id: @character.id,
              character_name: @character.name,
              character_type: character_type,
              passed: passed,
              is_boss_check: true
            }
          )
        else
          @fight.fight_events.create!(
            event_type: "up_check",
            description: "#{@character.name} #{passed ? 'succeeded' : 'failed'} the Up Check (#{total} vs #{UP_CHECK_THRESHOLD})",
            details: {
              character_id: @character.id,
              character_name: @character.name,
              character_type: character_type,
              swerve: @swerve,
              fortune: @fortune,
              toughness: toughness,
              total: total,
              threshold: UP_CHECK_THRESHOLD,
              passed: passed,
              marks_of_death: @character.action_values["Marks of Death"],
              fortune_used: fortune_used
            }
          )
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
    
    Rails.logger.info "🎲 UP CHECK COMPLETE: #{@character.name}"
    
    result
  end

  private

  def validate_up_check_eligibility!
    unless @character.up_check_required?
      raise ArgumentError, "Character does not require an Up Check"
    end
    
    character_type = @character.action_values["Type"]
    valid_types = ["PC", "Ally", "Boss", "Uber-Boss"]
    
    unless valid_types.include?(character_type)
      raise ArgumentError, "Only PCs, Allies, Bosses, and Uber-Bosses can make Up Checks"
    end
  end

  def handle_fortune_usage!
    return false if @fortune <= 0
    
    # Only PCs can use Fortune
    unless @character.is_pc?
      return false
    end
    
    current_fortune = @character.action_values["Fortune"] || 0
    
    if current_fortune < 1
      raise ActiveRecord::RecordInvalid.new(@character), "Insufficient Fortune points"
    end
    
    # Deduct Fortune point
    @character.action_values["Fortune"] = current_fortune - 1
    @character.save!
    
    Rails.logger.info "🎲 Spent 1 Fortune point from #{@character.name}, now at #{@character.action_values['Fortune']}"
    
    # Add extra Mark of Death for using Fortune
    increment_marks_of_death!
    
    true
  end

  def increment_marks_of_death!
    marks = @character.action_values["Marks of Death"] || 0
    @character.action_values["Marks of Death"] = marks + 1
    @character.save!
    
    Rails.logger.info "💀 Added Mark of Death to #{@character.name}, now at #{@character.action_values['Marks of Death']}"
  end
end