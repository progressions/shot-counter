class Api::V1::WeaponsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    @weapons = current_campaign.weapons

    @weapons = paginate(@weapons, per_page: (params[:per_page] || 24), page: (params[:page] || 1))

    render json: {
      weapons: @weapons,
      meta: pagination_meta(@weapons)
    }
  end

  def show
    @weapon = current_campaign.weapons.find(params[:id])

    render json: @weapon
  end

  def create
    @weapon = current_campaign.weapons.new(weapon_params)
    if @weapon.save
      render json: @weapon
    else
      render json: @weapon, status: 400
    end
  end

  def update
    @weapon = current_campaign.weapons.find(params[:id])
    if @weapon.update(weapon_params)
      render json: @weapon
    else
      render json: @weapon, status: 400
    end
  end

  def destroy
    @weapon = current_campaign.weapons.find(params[:id])
    if @weapon.destroy!
      render :ok
    else
      render json: @weapon, status: 400
    end
  end

  private

  def weapon_params
    params.require(:weapon).permit(:name, :description, :damage, :concealment, :reload_value)
  end

  def pagination_meta(object)
    {
      current_page: object.current_page,
      next_page: object.next_page,
      prev_page: object.prev_page,
      total_pages: object.total_pages,
      total_count: object.total_count
    }
  end
end
