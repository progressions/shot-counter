class Api::V1::WeaponsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    if params[:character_id].present?
      @character = current_campaign.characters.find(params[:character_id])
      @weapons = @character.weapons
    else
      @weapons = current_campaign
        .weapons
        .order(:juncture, :name)
    end

    @weapons = paginate(@weapons, per_page: (params[:per_page] || 24), page: (params[:page] || 1))

    @junctures = @weapons.pluck(:juncture).uniq.compact

    if params[:juncture].present?
      @weapons = @weapons.where(juncture: params[:juncture])
    end

    if params[:name].present?
      @weapons = @weapons.where("name ILIKE ?", "%#{params[:name]}%")
    end

    render json: {
      weapons: @weapons,
      meta: pagination_meta(@weapons),
      junctures: @junctures
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
      render json: @weapon.errors, status: 400
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
    params.require(:weapon).permit(:name, :description, :damage, :concealment, :reload_value, :juncture, :mook_bonus, :category, :kachunk)
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
