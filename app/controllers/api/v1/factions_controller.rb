class Api::V1::FactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    @factions = current_campaign.factions.order("LOWER(factions.name) ASC")

    if params[:id].present?
      @factions = @factions.where(id: params[:id])
    end
    if params[:show_all] == "true" && current_user.gamemaster?
      @factions = @factions.where(active: [true, false])
    else
      @factions = @factions.where(active: true)
    end
    if params[:search].present?
      @factions = @factions.where("name ILIKE ?", "%#{params[:search]}%")
    end
    if params[:character_id].present?
      character = current_campaign.characters.find(params[:character_id])
      @factions = @factions.where.not(id: character.faction_id)
    end

    @factions = paginate(@factions, per_page: (params[:per_page] || 10), page: (params[:page] || 1))

    render json: {
      factions: @factions,
      meta: pagination_meta(@factions)
    }
  end

  def show
    render json: current_campaign.factions.find(params[:id])
  end

  def create
    faction = current_campaign.factions.build(faction_params)
    if faction.save
      render json: faction, status: :created
    else
      render json: { errors: faction.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    faction = current_campaign.factions.find(params[:id])
    if faction.update(faction_params)
      render json: faction
    else
      render json: { errors: faction.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    faction = current_campaign.factions.find(params[:id])
    faction.destroy
    head :ok
  end

  def remove_image
    faction = current_campaign.factions.find(params[:id])
    faction.image.purge if faction.image.attached?
    render json: faction
  end

  private

  def faction_params
    params.require(:faction).permit(:name, :description, :active, :image)
  end
end
