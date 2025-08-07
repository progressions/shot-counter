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

  private

  def set_fight
    @fight = current_campaign.fights.find(params[:id])
  end

  def shot_params
    params.require(:character).permit(:current_shot)
  end
end
