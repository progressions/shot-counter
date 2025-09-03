class Api::V2::ShotsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_fight
  before_action :set_shot, only: [:update, :destroy]

  def update
    # Handle driver linkage if updating a vehicle shot
    if @shot.vehicle_id && params[:shot][:driver_id].present?
      # Clear any existing driver linkage for this vehicle
      @fight.shots.where(driving_id: @shot.id).update_all(driving_id: nil)
      
      # Set up new driver linkage
      driver_shot_id = params[:shot][:driver_id]
      if driver_shot_id.present? && driver_shot_id != ""
        driver_shot = @fight.shots.find_by(id: driver_shot_id)
        if driver_shot && driver_shot.character_id
          # Link the driver shot to this vehicle
          driver_shot.update(driving_id: @shot.id)
        end
      end
    end
    
    # Handle clearing driver if setting to empty
    if @shot.vehicle_id && params[:shot].key?(:driver_id) && params[:shot][:driver_id].blank?
      # Clear any existing driver linkage for this vehicle
      @fight.shots.where(driving_id: @shot.id).update_all(driving_id: nil)
    end
    
    if @shot.update(shot_params)
      # The broadcast is handled by the Shot model's after_update callback
      # Touch is handled by belongs_to :fight, touch: true in Shot model
      
      render json: { success: true }
    else
      render json: @shot.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @shot.destroy!
    
    # The fight is touched by belongs_to :fight, touch: true in Shot model
    # Broadcast will be handled by fight's after_touch callback
    
    head :no_content
  end

  private

  def set_fight
    @fight = current_campaign.fights.find(params[:fight_id])
  end

  def set_shot
    @shot = @fight.shots.find(params[:id])
  end

  def shot_params
    params.require(:shot).permit(:location, :shot, :impairments, :count, :driver_id, :driving_id)
  end
end