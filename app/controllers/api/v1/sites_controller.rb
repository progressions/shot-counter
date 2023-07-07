class Api::V1::SitesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    @sites = current_campaign.sites.order(:name)

    @factions = current_campaign.factions.joins(:sites).where(sites: @sites).order("factions.name").distinct

    if params[:private] == "true" && current_user.gamemaster?
      @sites = @sites.where(private: [true, false])
    else
      @sites = @sites.where(private: false)
    end
    if params[:search].present?
      @sites = @sites.where("name ILIKE ?", "%#{params[:search]}%")
    end
    if params[:faction_id].present?
      @sites = @sites.where(faction_id: params[:faction_id])
    end
    if params[:character_id].present?
      @site_ids = Attunement.where(site_id: @sites).where(character_id: params[:character_id]).pluck(:site_id)
      @sites = @sites.where.not(id: @site_ids)
    end

    @sites = paginate(@sites, per_page: (params[:per_page] || 24), page: (params[:page] || 1))

    render json: {
      sites: @sites,
      factions: @factions,
      meta: pagination_meta(@sites),
    }
  end

  def show
    render json: current_campaign.sites.find(params[:id])
  end

  def create
    site = current_campaign.sites.create(site_params)

    render json: site
  end

  def update
    site = current_campaign.sites.find(params[:id])
    site.update(site_params)

    render json: site
  end

  def destroy
    site = current_campaign.sites.find(params[:id])
    site.destroy

    render :ok
  end

  private

  def site_params
    params.require(:site).permit(:name, :description, :faction_id, :private)
  end
end
