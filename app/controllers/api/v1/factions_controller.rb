class Api::V1::FactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    @factions = current_campaign.factions.order("LOWER(factions.name) ASC")

    @factions = current_campaign.factions.joins(:factions).where(factions: @factions).order("factions.name").distinct

    if params[:show_all] == "true" && current_user.gamemaster?
      @factions = @factions.where(active: [true, false])
    else
      @factions = @factions.where(active: true)
    end
    if params[:search].present?
      @factions = @factions.where("name ILIKE ?", "%#{params[:search]}%")
    end
    if params[:character_id].present?
      @faction_ids = Attunement.where(faction_id: @factions).where(character_id: params[:character_id]).pluck(:faction_id)
      @factions = @factions.where.not(id: @faction_ids)
    end

    @factions = paginate(@factions, per_page: (params[:per_page] || 10), page: (params[:page] || 1))

    render json: {
      factions: @factions,
      meta: pagination_meta(@factions),
    }
  end

  def show
    render json: current_campaign.factions.find(params[:id])
  end

  def create
    faction = current_campaign.factions.create(faction_params)

    render json: faction
  end

  def update
    faction = current_campaign.factions.find(params[:id])
    faction.update(faction_params)

    render json: faction
  end

  def destroy
    faction = current_campaign.factions.find(params[:id])
    faction.destroy

    render :ok
  end

  def remove_image
    @faction = current_campaign.factions.find(params[:id])
    @faction.image.purge

    if @faction.save
      render json: @faction
    else
      render @faction.errors, status: 400
    end
  end

  private

  def faction_params
    params.require(:faction).permit(:name, :description, :active, :image)
  end
end
