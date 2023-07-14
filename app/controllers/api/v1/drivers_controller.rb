class Api::V1::DriversController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_fight
  before_action :set_vehicle, only: [:update, :destroy, :act, :reveal, :hide]
  before_action :set_shot, only: [:update, :destroy, :act, :reveal, :hide]

  def index
    render json: @fight.vehicles
  end

  def act
    if @shot.act!(shot_cost: params[:shots] || 3)
      render json: @vehicle
    else
      render json: @vehicle.errors, status: 400
    end
  end

  def add
    @vehicle = current_campaign.vehicles.find(params[:id])
    @shot = @fight.shots.build(vehicle_id: @vehicle.id, shot: shot_params[:current_shot])
    if @vehicle.action_values["Type"] == "Mook"
      @shot.mook = Mook.new(count: @vehicle.action_values["Chase Points"], color: character_params[:color])
    end

    if @shot.save
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
    @vehicle = current_campaign.vehicles.create!(vehicle_params.merge(user: current_user))
    @shot = @fight.shots.build(vehicle_id: @vehicle.id, shot: shot_params[:current_shot])
    if @vehicle.action_values["Type"] == "Mook"
      @shot.mook = Mook.new(count: @vehicle.action_values["Chase Points"], color: character_params[:color])
    end

    if @shot.save
      render json: @vehicle
    else
      render status: 400
    end
  end

  def update
    @shot.update(shot: shot_params[:current_shot]) if shot_params[:current_shot]
    if @vehicle.update(vehicle_params)
      render json: @vehicle
    else
      render @vehicle.errors, status: 400
    end
  end

  def reveal
    @shot.update(shot: 0)

    render json: @vehicle
  end

  def hide
    @shot.update(shot: nil)

    render json: @vehicle
  end

  def destroy
    @shot.destroy!
    render :ok
  end

  private

  def set_vehicle
    @vehicle = @fight.vehicles.find(params[:id])
  end

  def set_shot
    @shot = @fight.shots.find_or_create_by(vehicle_id: @vehicle.id)
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
