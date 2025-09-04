class BoostService
  BOOST_SHOT_COST = 3
  
  BOOST_VALUES = {
    attack: { base: 1, fortune: 2 },
    defense: { base: 3, fortune: 5 }
  }.freeze

  def self.apply_boost(fight, booster_id:, target_id:, boost_type:, use_fortune:)
    new(fight, booster_id: booster_id, target_id: target_id, boost_type: boost_type, use_fortune: use_fortune).apply
  end

  def initialize(fight, booster_id:, target_id:, boost_type:, use_fortune:)
    @fight = fight
    @booster_id = booster_id
    @target_id = target_id
    @boost_type = boost_type.to_sym
    @use_fortune = ActiveModel::Type::Boolean.new.cast(use_fortune)
  end

  def apply
    result = nil
    
    ActiveRecord::Base.transaction do
      # Disable individual broadcasts during the transaction
      Thread.current[:disable_broadcasts] = true
      
      begin
        # Find shots for booster and target
        @booster_shot = @fight.shots.find_by!(character_id: @booster_id)
        @target_shot = @fight.shots.find_by!(character_id: @target_id)
        
        @booster = @booster_shot.character
        @target = @target_shot.character
        
        # Validate boost type
        unless [:attack, :defense].include?(@boost_type)
          raise ArgumentError, "Invalid boost type: #{@boost_type}"
        end
        
        # Determine if Fortune can be used (PC only)
        can_use_fortune = @booster.is_pc? && @use_fortune
        
        # Validate Fortune availability if requested
        if can_use_fortune
          current_fortune = @booster.action_values["Fortune"] || 0
          if current_fortune < 1
            raise ActiveRecord::RecordInvalid.new(@booster), "Insufficient Fortune points"
          end
        end
        
        # Calculate boost value
        boost_value = can_use_fortune ? BOOST_VALUES[@boost_type][:fortune] : BOOST_VALUES[@boost_type][:base]
        
        # Deduct shot cost from booster
        @booster_shot.shot -= BOOST_SHOT_COST
        @booster_shot.save!
        Rails.logger.info "💪 Deducted #{BOOST_SHOT_COST} shots from #{@booster.name}, now at shot #{@booster_shot.shot}"
        
        # Spend Fortune point if applicable
        if can_use_fortune
          @booster.action_values["Fortune"] -= 1
          @booster.save!
          Rails.logger.info "🎲 Spent 1 Fortune point from #{@booster.name}, now at #{@booster.action_values['Fortune']}"
        end
        
        # Create the CharacterEffect for the target
        effect_name = @boost_type == :attack ? "Attack Boost" : "Defense Boost"
        effect_name += " (Fortune)" if can_use_fortune
        
        # Determine which action value to boost
        action_value = if @boost_type == :attack
          # Use the target's main attack type
          @target.action_values["MainAttack"] || "Guns"
        else
          "Defense"
        end
        
        effect = CharacterEffect.create!(
          character: @target,
          shot: @target_shot,
          name: effect_name,
          action_value: action_value,
          change: "+#{boost_value}",
          description: "Boost from #{@booster.name}",
          severity: "info"
        )
        
        Rails.logger.info "✨ Created #{effect_name} for #{@target.name}: #{action_value} #{effect.change}"
        
        # Create fight event for the boost
        @fight.fight_events.create!(
          event_type: "boost",
          description: "#{@booster.name} boosted #{@target.name}'s #{@boost_type} (+#{boost_value})",
          details: {
            booster_id: @booster.id,
            target_id: @target.id,
            boost_type: @boost_type.to_s,
            boost_value: boost_value,
            fortune_used: can_use_fortune
          }
        )
        
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
    
    Rails.logger.info "💪 BOOST COMPLETE: #{@booster.name} boosted #{@target.name}'s #{@boost_type}"
    
    result
  end
end