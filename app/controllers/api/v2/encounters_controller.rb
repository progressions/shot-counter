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
    @fight.touch
    if @shot.act!(shot_cost: params[:shots] || Fight::DEFAULT_SHOT_COUNT)
      render json: @fight, serializer: EncounterSerializer
    else
      render json: @shot.errors, status: :bad_request
    end
  end

  def apply_combat_action
    character_updates = combat_action_params[:character_updates] || []

    Rails.logger.info "🔄 BATCHED COMBAT: Applying #{character_updates.length} character updates to fight #{@fight.id}"

    result = CombatActionService.apply_combat_action(@fight, character_updates)

    render json: result, serializer: EncounterSerializer
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: "Resource not found: #{e.message}" }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue ArgumentError => e
    render json: { error: e.message }, status: :bad_request
  rescue StandardError => e
    Rails.logger.error "Error applying combat action: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { error: "Failed to apply combat action" }, status: :internal_server_error
  end

  private

  def set_fight
    @fight = current_campaign.fights.find(params[:id])
  end

  def shot_params
    params.require(:character).permit(:current_shot)
  end

  def combat_action_params
    params.permit(character_updates: [
      :shot_id, :character_id, :vehicle_id, :shot, :wounds, :count, 
      :impairments, :defense,
      action_values: {},
      attributes: {},
      event: [:type, :description, details: {}]
    ])
  end
end
