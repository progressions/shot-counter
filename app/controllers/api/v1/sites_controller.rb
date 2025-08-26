class Api::V1::SitesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    @sites = current_campaign.sites.order("LOWER(sites.name) ASC")

    @factions = current_campaign.factions.joins(:sites).where(sites: @sites).order("factions.name").distinct

    if params[:id].present?
      @sites = @sites.where(id: params[:id])
    end
    if params[:show_hidden] == "true" && current_user.gamemaster?
      # Show all sites (active and inactive) for gamemaster
      @sites = @sites
    else
      # Show only active sites for regular users
      @sites = @sites.where(active: true)
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

    @sites = paginate(@sites, per_page: (params[:per_page] || 10), page: (params[:page] || 1))

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

  def remove_image
    @site = current_campaign.sites.find(params[:id])
    @site.image.purge

    if @site.save
      render json: @site
    else
      render @site.errors, status: 400
    end
  end

  private

  def site_params
    params.require(:site).permit(:name, :description, :faction_id, :active, :image)
  end
end
