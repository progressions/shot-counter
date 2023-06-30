class Api::V1::SitesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    render json: current_campaign.sites
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
