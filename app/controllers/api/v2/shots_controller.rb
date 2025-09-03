class Api::V2::ShotsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_fight
  before_action :set_shot, only: [:update, :destroy, :assign_driver, :remove_driver]

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

  def assign_driver
    # Validate this is a vehicle shot
    unless @shot.vehicle_id
      return render json: { error: "Shot must contain a vehicle" }, status: :unprocessable_entity
    end

    driver_shot_id = params[:driver_shot_id]
    driver_shot = @fight.shots.find_by(id: driver_shot_id)

    # Validate driver shot exists
    unless driver_shot
      return render json: { error: "Driver shot not found" }, status: :not_found
    end

    # Validate driver shot contains a character
    unless driver_shot.character_id
      return render json: { error: "Shot must contain a character to be a driver" }, status: :unprocessable_entity
    end

    # Clear any existing driver for this vehicle
    @fight.shots.where(driving_id: @shot.id).update_all(driving_id: nil)

    # Assign the new driver
    driver_shot.update!(driving_id: @shot.id)

    # Broadcast the update
    ActionCable.server.broadcast(
      "fight_#{@fight.id}",
      {
        event: "driver_assigned",
        vehicle_shot_id: @shot.id,
        driver_shot_id: driver_shot.id
      }
    )

    render json: { success: true, message: "Driver assigned successfully" }
  end

  def remove_driver
    # Validate this is a vehicle shot
    unless @shot.vehicle_id
      return render json: { error: "Shot must contain a vehicle" }, status: :unprocessable_entity
    end

    # Clear any driver for this vehicle
    @fight.shots.where(driving_id: @shot.id).update_all(driving_id: nil)

    # Broadcast the update
    ActionCable.server.broadcast(
      "fight_#{@fight.id}",
      {
        event: "driver_removed",
        vehicle_shot_id: @shot.id
      }
    )

    render json: { success: true, message: "Driver removed successfully" }
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