class Api::V2::EncountersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_fight

  def show
    render json: @fight, serializer: EncounterSerializer
  rescue ActiveRecord::RecordNotFound
    render json: { "error" => "Encounter not found" }, status: :not_found
  end

  def act
    if params[:action_id]
      @fight.update(action_id: params[:action_id]) # Save action_id to Fight
    end
    @shot = @fight.shots.find(params[:shot_id])
    shot_cost = params[:shots] || Fight::DEFAULT_SHOT_COUNT
    entity = @shot.character || @shot.vehicle
    entity_name = entity&.name || "Unknown"
    
    @fight.touch
    if @shot.act!(shot_cost: shot_cost)
      # Create a fight event for the movement
      @fight.fight_events.create!(
        event_type: "movement",
        description: "#{entity_name} spent #{shot_cost} #{shot_cost.to_i == 1 ? 'shot' : 'shots'}",
        details: {
          entity_id: entity&.id,
          entity_type: entity&.class&.name,
          shot_cost: shot_cost.to_i,
          new_shot: @shot.shot
        }
      )
      
      render json: @fight, serializer: EncounterSerializer
    else
      render json: @shot.errors, status: :bad_request
    end
  end

  def update_initiatives
    shots_data = params[:shots] || []
    
    Rails.logger.info "🎲 INITIATIVE UPDATE: Updating #{shots_data.length} shot values for fight #{@fight.id}"
    
    ActiveRecord::Base.transaction do
      shots_data.each do |shot_data|
        shot = @fight.shots.find(shot_data[:id])
        shot.update!(shot: shot_data[:shot])
        Rails.logger.info "  Updated shot #{shot.id}: #{shot.character&.name || shot.vehicle&.name} to shot #{shot_data[:shot]}"
      end
    end
    
    # Broadcast the update after all shots are updated
    @fight.broadcast_encounter_update!
    
    render json: @fight, serializer: EncounterSerializer
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: "Shot not found: #{e.message}" }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_content
  rescue StandardError => e
    Rails.logger.error "Error updating initiatives: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { error: "Failed to update initiatives" }, status: :internal_server_error
  end

  def apply_combat_action
    # Check if this is a boost action
    if params[:action_type] == "boost"
      Rails.logger.info "💪 BOOST ACTION: Processing boost for fight #{@fight.id}"
      result = BoostService.apply_boost(
        @fight,
        booster_id: params[:booster_id],
        target_id: params[:target_id],
        boost_type: params[:boost_type],
        use_fortune: params[:use_fortune]
      )
    elsif params[:action_type] == "up_check"
      Rails.logger.info "🎲 UP CHECK ACTION: Processing Up Check for fight #{@fight.id}"
      result = UpCheckService.apply_up_check(
        fight: @fight,
        character_id: params[:character_id],
        swerve: params[:swerve],
        fortune: params[:fortune] || 0
      )
    else
      character_updates = combat_action_params[:character_updates] || []
      Rails.logger.info "🔄 BATCHED COMBAT: Applying #{character_updates.length} character updates to fight #{@fight.id}"
      result = CombatActionService.apply_combat_action(@fight, character_updates)
    end

    render json: result, serializer: EncounterSerializer
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: "Resource not found: #{e.message}" }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_content
  rescue ArgumentError => e
    render json: { error: e.message }, status: :bad_request
  rescue StandardError => e
    Rails.logger.error "Error applying combat action: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { error: "Failed to apply combat action" }, status: :internal_server_error
  end

  def apply_chase_action
    vehicle_updates = chase_action_params[:vehicle_updates] || []

    Rails.logger.info "🏎️ CHASE ACTION: Applying #{vehicle_updates.length} vehicle updates to fight #{@fight.id}"

    result = ChaseActionService.apply_chase_action(@fight, vehicle_updates)

    render json: result, serializer: EncounterSerializer
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: "Resource not found: #{e.message}" }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_content
  rescue ArgumentError => e
    render json: { error: e.message }, status: :bad_request
  rescue StandardError => e
    Rails.logger.error "Error applying chase action: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { error: "Failed to apply chase action" }, status: :internal_server_error
  end

  private

  def set_fight
    @fight = current_campaign.fights.find(params[:id])
  end

  def shot_params
    params.require(:character).permit(:current_shot)
  end

  def combat_action_params
    params.permit(
      :action_type, :booster_id, :target_id, :boost_type, :use_fortune,
      :character_id, :swerve, :fortune,  # Up Check parameters
      character_updates: [
        :shot_id, :character_id, :vehicle_id, :shot, :wounds, :count, 
        :impairments, :defense,
        add_status: [],
        remove_status: [],
        action_values: {},
        attributes: {},
        event: [:type, :description, details: {}]
      ]
    )
  end

  def chase_action_params
    params.permit(vehicle_updates: [
      :vehicle_id,
      :target_vehicle_id,
      :character_id,
      :shot_cost,
      :fortune_spent,
      :role,
      :position,
      :action_type,
      action_values: {},
      event: [:type, :description, details: {}]
    ])
  end
end
