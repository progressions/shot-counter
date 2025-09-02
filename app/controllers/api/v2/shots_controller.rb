class Api::V2::ShotsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_fight
  before_action :set_shot

  def update
    if @shot.update(shot_params)
      # Broadcast the encounter update
      @fight.touch
      @fight.send(:broadcast_encounter_update!)
      
      render json: { success: true }
    else
      render json: @shot.errors, status: :unprocessable_entity
    end
  end

  private

  def set_fight
    @fight = current_campaign.fights.find(params[:fight_id])
  end

  def set_shot
    @shot = @fight.shots.find(params[:id])
  end

  def shot_params
    params.require(:shot).permit(:location)
  end
end