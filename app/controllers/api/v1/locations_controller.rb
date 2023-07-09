class Api::V1::LocationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_fight, only: [:index, :create]
  before_action :set_shot, only: [:index, :create]

  def index
    @location = @shot.location

    render json: @location
  end

  def create
    if location_params[:name].blank?
      @shot.location.destroy!

      render :ok and return
    end

    @location = @shot.build_location(location_params)

    if @location.save
      render json: @location, status: :created
    else
      render json: @location.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @location = Location.find(params[:id])
    @location.shot.update(location_id: nil)
    @location.destroy
  end

  private

  def location_params
    params.require(:location).permit(:name)
  end

  def set_shot
    if params[:character_id]
      @shot = @fight.shots.find_by(character_id: params[:character_id])
    elsif params[:vehicle_id]
      @shot = @fight.shots.find_by(vehicle_id: params[:vehicle_id])
    end
  end

  def set_fight
    @fight = current_campaign.fights.find(params[:fight_id])
  end
end
