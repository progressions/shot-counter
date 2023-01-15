class Api::V1::AllVehiclesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_scoped_vehicles
  before_action :set_vehicle, only: [:update, :destroy, :show]

  def index
    @vehicles = @scoped_vehicles.includes(:user).order(:name).all
    render json: @vehicles
  end

  def create
    @vehicle = Vehicle.create!(vehicle_params)
    @vehicle.user = current_user

    if @vehicle.save
      render json: @vehicle
    else
      render status: 400
    end
  end

  def show
    render json: @vehicle
  end

  def update
    if @vehicle.update(vehicle_params)
      render json: @vehicle
    else
      render @vehicle.errors, status: 400
    end
  end

  def destroy
    @vehicle.destroy!
    render :ok
  end

  private

  def set_vehicle
    @vehicle = @scoped_vehicles.find(params[:id])
  end

  def set_scoped_vehicles
    if current_user.gamemaster?
      @scoped_vehicles = Vehicle
    else
      @scoped_vehicles = current_user.vehicles
    end
  end

  def vehicle_params
    params.require(:vehicle).permit(:name, :defense, :impairments, :color, :user_id, action_values: Vehicle::DEFAULT_ACTION_VALUES.keys)
  end

end