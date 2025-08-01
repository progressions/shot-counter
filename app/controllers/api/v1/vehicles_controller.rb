class Api::V1::VehiclesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_scoped_vehicles
  before_action :set_vehicle, only: [:update, :destroy, :show]

  def index
    sort = params[:sort] || "created_at"
    order = params[:order] || "DESC"

    @vehicles = @scoped_vehicles
      .includes(:user)
      .order(sort => order)

    if params[:user_id]
      @vehicles = @vehicles.where(user_id: params[:user_id])
    end
    @vehicles = paginate(@vehicles, per_page: (params[:per_page] || 10), page: (params[:page] || 1))

    render json: {
      vehicles: @vehicles,
      meta: pagination_meta(@vehicles),
    }
  end

  def archetypes
    @archetypes = VehicleService.archetypes["vehicles"]
    render json: @archetypes
  end

  def create
    @vehicle = current_campaign.vehicles.create!(vehicle_params)
    @vehicle.user = current_user
    @vehicle.campaign = current_campaign

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

  def remove_image
    @vehicle.image.purge

    if @vehicle.save
      render json: @vehicle
    else
      render @vehicle.errors, status: 400
    end
  end

  private

  def set_vehicle
    @vehicle = @scoped_vehicles.find(params[:id])
  end

  def set_scoped_vehicles
    if current_user.gamemaster?
      @scoped_vehicles = current_campaign.vehicles
    else
      @scoped_vehicles = current_user.vehicles
    end
  end

  def vehicle_params
    params.require(:vehicle).permit(:name, :character_id, :faction_id, :defense,
      :impairments, :count, :color, :user_id, :active, :image_url, :image, :task,
      :action_values)
  end

end
