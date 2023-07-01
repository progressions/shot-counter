class Api::V1::SitesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    @sites = current_campaign.sites

    if params[:character_id].present?
      @sites = current_campaign.sites
      @site_ids = Attunement.where(site_id: @sites).where(character_id: params[:character_id]).pluck(:site_id)
      @sites = @sites.where.not(id: @site_ids)
    end

    @sites = paginate(@sites, per_page: (params[:per_page] || 24), page: (params[:page] || 1))

    render json: {
      sites: @sites,
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
    params.require(:site).permit(:name, :description)
  end
end
