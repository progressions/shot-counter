class Api::V1::CharacterSitesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_character

  def index
    @sites = @character.sites.order(:created_at)

    render json: @sites
  end

  def create
    @site = @character.sites.new(site_params)

    if @site.save
      render json: @site
    else
      render json: @site, status: 422
    end
  end

  def show
    @site = @character.sites.find(params[:id])

    render json: @site
  end

  def update
    @site = @character.sites.find(params[:id])

    if @site.update(site_params)
      render json: @site
    else
      render json: @site, status: 422
    end
  end

  def destroy
    @site = @character.sites.find(params[:id])

    if @site.destroy
      render status: 200
    else
      render json: @site, status: 422
    end
  end

  private

  def site_params
    params.require(:site).permit(:description)
  end

  def set_character
    @character = current_campaign.characters.find(params[:character_id])
  end
end
