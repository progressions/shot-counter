class Api::V2::SitesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    @sites = current_campaign.sites.order("LOWER(sites.name) ASC")

    @factions = current_campaign.factions.joins(:sites).where(sites: @sites).order("factions.name").distinct

    if params[:id].present?
      @sites = @sites.where(id: params[:id])
    end
    if params[:secret] == "true" && current_user.gamemaster?
      @sites = @sites.where(secret: [true, false])
    else
      @sites = @sites.where(secret: false)
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
    # Check if request is multipart/form-data with a JSON string
    if params[:site].present? && params[:site].is_a?(String)
      begin
        site_data = JSON.parse(params[:site]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid site data format" }, status: :bad_request
        return
      end
    else
      site_data = site_params.to_h.symbolize_keys
    end

    site_data.slice(:name, :description, :active, :faction_id)

    @site = current_campaign.sites.new(site_data)

    # Handle image attachment if present
    if params[:image].present?
      @site.image.attach(params[:image])
    end

    if @site.save
      render json: @site, status: :created
    else
      render json: { errors: @site.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @site = current_campaign.sites.find(params[:id])

    # Handle multipart/form-data for updates if present
    if params[:site].present? && params[:site].is_a?(String)
      begin
        site_data = JSON.parse(params[:site]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid site data format" }, status: :bad_request
        return
      end
    else
      site_data = site_params.to_h.symbolize_keys
    end
    site_data = site_data.slice(:name, :description, :active, :faction_id)

    # Handle image attachment if present
    if params[:image].present?
      begin
        @site.image.purge if @site.image.attached? # Remove existing image
        @site.image.attach(params[:image])
      rescue StandardError => e
        Rails.logger.error("Error uploading to ImageKit")
      end
    end

    if @site.update(site_data)
      render json: @site
    else
      render json: { errors: @site.errors.full_messages }, status: :unprocessable_entity
    end
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
    params.require(:site).permit(:name, :description, :faction_id, :secret, :image)
  end
end
