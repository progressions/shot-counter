class Api::V1::AttunementsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_character

  def index
    @sites = @character.sites.order(:created_at)

    render json: @sites
  end

  def create
    if site_params[:id].present?
      @site = current_campaign.sites.find(site_params[:id])
    else
      @site = current_campaign.sites.find_or_create_by(name: site_params[:name])
    end

    if @character.sites << @site
      render json: @site
    else
      render json: @site, status: 422
    end
  end

  def destroy
    @attunement = @character.attunements.find_by(site_id: params[:id])

    if @attunement.destroy
      render :ok
    else
      render json: @site, status: 422
    end
  end

  private

  def site_params
    params.require(:site).permit(:name, :description, :id)
  end

  def set_character
    @character = current_campaign.characters.find(params[:character_id])
  end
end
