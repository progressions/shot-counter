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

  def update_combat_state
    @shot = @fight.shots.find(params[:shot_id])
    
    # Update wounds and impairments based on character type
    if @shot.character&.is_pc?
      # For PCs, update the character record (persistent)
      @shot.character.action_values["Wounds"] = params[:wounds] || 0
      @shot.character.impairments = params[:impairments] || 0
      
      # Update Fortune points if provided
      if params[:fortune].present?
        @shot.character.action_values["Fortune"] = params[:fortune]
      end
      
      @shot.character.save!
    else
      # For NPCs and vehicles, update the shot record (fight-specific)
      @shot.count = params[:count] || 0  # Wounds for NPCs, mook count for Mooks
      @shot.impairments = params[:impairments] || 0
      @shot.save!
    end
    
    # Log the combat event if provided
    if params[:event].present?
      @fight.fight_events.create!(
        event_type: params[:event][:type] || "combat",
        description: params[:event][:description] || "Combat state updated",
        details: params[:event][:details] || {}
      )
    end
    
    # Touch the fight to trigger ActionCable broadcast
    Rails.logger.info "🔄 WEBSOCKET: Touching fight #{@fight.id} to trigger broadcast"
    @fight.touch
    Rails.logger.info "🔄 WEBSOCKET: Fight touched, broadcasting should happen via after_update callbacks"
    
    render json: @fight, serializer: EncounterSerializer
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Shot not found" }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_fight
    @fight = current_campaign.fights.find(params[:id])
  end

  def shot_params
    params.require(:character).permit(:current_shot)
  end
  
  def combat_state_params
    params.permit(:shot_id, :wounds, :count, :impairments, 
                  event: [:type, :description, details: {}])
  end
end
