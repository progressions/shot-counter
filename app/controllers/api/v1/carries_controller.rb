class Api::V1::CarriesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_character

  def index
    @weapons = @character.weapons.order(:juncture, :name)
    @weapons = paginate(@weapons, per_page: (params[:per_page] || 10), page: (params[:page] || 1))
    @junctures = @weapons.pluck(:juncture).uniq.compact
    @categories = @weapons.where.not(category: "").pluck(:category).uniq.compact

    render json: {
      weapons: @weapons,
      meta: pagination_meta(@weapons),
      junctures: @junctures,
      categories: @categories
    }
  end

  def create
    @weapon = current_campaign.weapons.find_by(id: weapon_params[:id])
    if @character.weapons << @weapon
      render json: @character
    else
      render json: @character, status: 400
    end
  end

  def destroy
    @carry = @character.carries.find_by(weapon_id: params[:id])

    if @carry.destroy
      render :ok
    else
      render json: @character.errors, status: 400
    end
  end

  private

  def weapon_params
    params.require(:weapon).permit(:id)
  end

  def set_character
    @character = current_campaign.characters.find(params[:character_id])
  end
end
