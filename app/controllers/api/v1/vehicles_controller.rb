class Api::V1::VehiclesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_fight
  before_action :set_vehicle, only: [:update, :destroy, :act]
  before_action :set_fight_vehicle, only: [:update, :destroy, :act]

  def index
    render json: @fight.vehicles
  end

  def act
    if @fight_vehicle.act!(shot_cost: params[:shots] || 3)
      render json: @vehicle
    else
      render json: @vehicle.errors, status: 400
    end
  end

  def add
    @vehicle = current_campaign.vehicles.find(params[:id])
    @fight_vehicle = @fight.fight_characters.build(vehicle_id: @vehicle.id, shot: shot_params[:current_shot])

    if @fight_vehicle.save
      render json: @vehicle
    else
      render status: 400
    end
  end

  def show
    @vehicle = @fight.vehicles.find(params[:id])
    render json: @vehicle
  end

  def create
    @vehicle = Vehicle.create!(vehicle_params)
    @vehicle.user = current_user
    @vehicle.campaign = current_campaign
    @fight_vehicle = @fight.fight_characters.build(vehicle_id: @vehicle.id, shot: shot_params[:current_shot])

    if @fight_vehicle.save
      render json: @vehicle
    else
      render status: 400
    end
  end

  def update
    @fight_vehicle.update(shot: shot_params[:current_shot]) if shot_params[:current_shot]
    if @vehicle.update(vehicle_params)
      render json: @vehicle
    else
      render @vehicle.errors, status: 400
    end
  end

  def destroy
    @fight_vehicle.destroy!
    render :ok
  end

  private

  def set_vehicle
    @vehicle = @fight.vehicles.find(params[:id])
  end

  def set_fight_vehicle
    @fight_vehicle = @fight.fight_characters.find_or_create_by(vehicle_id: @vehicle.id)
  end

  def set_fight
    @fight = current_campaign.fights.find(params[:fight_id])
  end

  def shot_params
    params.require(:vehicle).permit(:current_shot)
  end

  def vehicle_params
    params.require(:vehicle).permit(:name, :defense, :impairments, :color, :user_id, action_values: Vehicle::DEFAULT_ACTION_VALUES.keys)
  end
end
