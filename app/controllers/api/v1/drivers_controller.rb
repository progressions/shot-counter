class Api::V1::DriversController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_fight
  before_action :set_vehicle, only: [:update, :act, :reveal, :hide]
  before_action :set_shot, only: [:update, :act, :reveal, :hide]

  def index
    render json: @fight.vehicles.order(:name)
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
    if @fight.shots.find_by(vehicle_id: @vehicle.id)
      @vehicle = DuplicateVehicleService.duplicate(@vehicle)
    end
    @shot = @fight.shots.build(vehicle_id: @vehicle.id, shot: shot_params[:current_shot])

    if @vehicle.action_values["Type"] == "Mook"
      @shot.update(count: @vehicle.action_values["Chase Points"], color: vehicle_params[:color])
    end

    if driver_params[:id]
      @shot.update(driver_id: driver_params[:id])
      @driver_shot = @fight.shots.find_by(character_id: driver_params[:id])
      @driver_shot.update(driving_id: @vehicle.id) if @driver_shot
    end

    if @shot.save
      render json: @vehicle.as_v1_json(shot: @shot)
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
      @shot.update(count: @vehicle.action_values["Chase Points"], color: vehicle_params[:color])
    end

    if @shot.save
      render json: @vehicle.as_v1_json(shot: @shot)
    else
      render status: 400
    end
  end

  def update
    current_shot = shot_params[:current_shot] == "hidden" ? nil : shot_params[:current_shot]
    @shot.update(shot: current_shot) if shot_params[:current_shot]

    parms = vehicle_params

    if @vehicle.action_values["Type"] == "Mook"
      count = params[:vehicle][:count]
      @shot.update(count: count, color: vehicle_params[:color])

      parms = mook_params
    end

    if driver_params[:shot_id]
      @shot.update(driver_id: driver_params[:shot_id])
      @driver_shot = @fight.shots.find_by(id: driver_params[:shot_id])
      @driver_shot.update(driving_id: @shot.id) if @driver_shot
    end

    if @vehicle.update(parms)
      render json: @vehicle.as_v1_json(shot: @shot)
    else
      render @vehicle.errors, status: 400
    end
  rescue

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
    @shot = Shot.find(params[:id])

    @shot.destroy!
    render :ok
  end

  private

  def set_vehicle
    @vehicle = @fight.vehicles.find(params[:id])
  end

  def set_shot
    @shot = @fight.shots.find_or_create_by(id: params[:vehicle][:shot_id], vehicle_id: params[:id])
  end

  def set_fight
    @fight = current_campaign.fights.find(params[:fight_id])
  end

  def shot_params
    params.require(:vehicle).permit(:current_shot)
  end

  def vehicle_params
    params.require(:vehicle).permit(:name, :impairments, :task,
                                    :color, :user_id, action_values: Vehicle::DEFAULT_ACTION_VALUES.keys)
  end

  def mook_params
    params
      .require(:vehicle)
      .permit(:name, :defense, :impairments, :color,
              :user_id, :active, skills: [],
              action_values: Vehicle::DEFAULT_ACTION_VALUES.keys - ["Chase Points"],
              schticks: [])
  end

  def driver_params
    params
      .require(:vehicle)
      .permit(driver: [:id, :shot_id])
      &.dig(:driver) || {}
  end

end
