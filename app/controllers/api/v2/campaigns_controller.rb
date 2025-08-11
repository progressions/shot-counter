class Api::V2::CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_gamemaster_or_admin, only: [:create, :update, :destroy, :remove_image]
  before_action :set_campaign, only: [:show, :set, :update, :remove_image]

  def index
    per_page = (params["per_page"] || 15).to_i
    page = (params["page"] || 1).to_i
    selects = [
      "campaigns.id",
      "campaigns.user_id",
      "campaigns.name",
      "campaigns.description",
      "campaigns.created_at",
      "campaigns.updated_at",
      "campaigns.active",
    ]
    includes = [
      :image_positions,
      image_attachment: :blob,
      characters: { image_attachment: :blob },
      vehicles: { image_attachment: :blob },
    ]
    query = if current_user.gamemaster? || current_user.admin?
              current_user.campaigns
            else
              current_user.player_campaigns
            end
    query = query.select(selects).includes(includes)
    # Apply filters
    query = query.where(id: params["id"]) if params["id"].present?
    query = query.where("campaigns.name ILIKE ?", "%#{params['search']}%") if params["search"].present?
    if params["show_all"] == "true"
      query = query.where(active: [true, false, nil])
    else
      query = query.where(active: true)
    end
    query = query.joins(:characters).where(characters: { id: params[:character_id] }) if params[:character_id].present?
    query = query.joins(:vehicles).where(vehicles: { id: params[:vehicle_id] }) if params[:vehicle_id].present?
    # Cache key
    cache_key = [
      "campaigns/index",
      current_user.id,
      sort_order,
      page,
      per_page,
      params["search"],
      params["autocomplete"],
      params["character_id"],
      params["vehicle_id"],
      params["show_all"],
    ].join("/")
    cached_result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      campaigns = query.order(Arel.sql(sort_order))
      campaigns = paginate(campaigns, per_page: per_page, page: page)
      {
        "campaigns" => ActiveModelSerializers::SerializableResource.new(
          campaigns,
          each_serializer: params[:autocomplete] ? CampaignAutocompleteSerializer : CampaignIndexSerializer,
          adapter: :attributes
        ).serializable_hash,
        "meta" => pagination_meta(campaigns)
      }
    end
    render json: cached_result
  end

  def create
    if params[:campaign].present? && params[:campaign].is_a?(String)
      begin
        campaign_data = JSON.parse(params[:campaign]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid campaign data format" }, status: :bad_request
        return
      end
    else
      campaign_data = campaign_params.to_h.symbolize_keys
    end
    campaign_data = campaign_data.slice(:name, :description, :active, :player_ids)
    @campaign = current_user.campaigns.new(campaign_data)
    if params[:image].present?
      @campaign.image.attach(params[:image])
    end
    if @campaign.save
      render json: @campaign, status: :created
    else
      render json: { errors: @campaign.errors }, status: :unprocessable_entity
    end
  end

  def update
    unless @campaign
      render json: { error: "Record not found or unauthorized" }, status: :not_found
      return
    end
    if params[:campaign].present? && params[:campaign].is_a?(String)
      begin
        campaign_data = JSON.parse(params[:campaign]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid campaign data format" }, status: :bad_request
        return
      end
    else
      campaign_data = campaign_params.to_h.symbolize_keys
    end
    campaign_data = campaign_data.slice(:name, :description, :active, :player_ids)
    if params[:image].present?
      @campaign.image.purge if @campaign.image.attached?
      @campaign.image.attach(params[:image])
    end
    if @campaign.update(campaign_data)
      render json: @campaign
    else
      render json: { errors: @campaign.errors }, status: :unprocessable_entity
    end
  end

  def show
    if @campaign
      render json: @campaign, serializer: CampaignSerializer, status: :ok
    else
      render json: { error: "Record not found or unauthorized" }, status: :not_found
    end
  end

  def destroy
    @campaign = (current_user.campaigns.find_by(id: params[:id]) if current_user.gamemaster?) || (Campaign.find_by(id: params[:id]) if current_user.admin?)
    unless @campaign
      render json: { error: "Record not found or unauthorized" }, status: :not_found
      return
    end
    if @campaign.id == current_campaign&.id
      render json: { error: "Cannot destroy the current campaign" }, status: :unauthorized
      return
    end
    if (@campaign.characters.any? || @campaign.vehicles.any? || @campaign.factions.any? || @campaign.junctures.any? || @campaign.fights.any?) && !params[:force]
      render json: { errors: { associations: true } }, status: :bad_request
      return
    end
    if params[:force]
      @campaign.characters.update_all(campaign_id: nil)
      @campaign.vehicles.update_all(campaign_id: nil)
      @campaign.factions.update_all(campaign_id: nil)
      @campaign.junctures.update_all(campaign_id: nil)
      @campaign.fights.update_all(campaign_id: nil)
    end
    if @campaign.destroy!
      render :ok
    else
      render json: { errors: @campaign.errors }, status: :bad_request
    end
  end

  def set
    save_current_campaign(@campaign)
    render json: @campaign
  end

  def remove_image
    unless @campaign
      render json: { error: "Record not found or unauthorized" }, status: :not_found
      return
    end
    @campaign.image.purge if @campaign.image.attached?
    if @campaign.save
      render json: @campaign
    else
      render json: { errors: @campaign.errors }, status: :unprocessable_entity
    end
  end

  private

  def require_gamemaster_or_admin
    unless current_user.gamemaster? || current_user.admin?
      render json: { error: "Gamemaster or admin access required" }, status: :forbidden
      return
    end
  end

  def set_campaign
    if params[:id] == "current"
      @campaign = current_campaign
    else
      @campaign = (current_user.campaigns.find_by(id: params[:id]) if current_user.gamemaster?) || (Campaign.find_by(id: params[:id]) if current_user.admin?) || current_user.player_campaigns.find_by(id: params[:id])
    end
  end

  def campaign_params
    params.require(:campaign).permit(:name, :description, :image, :active, player_ids: [])
  end

  def sort_order
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"
    if sort == "name"
      "LOWER(campaigns.name) #{order}"
    elsif sort == "created_at"
      "campaigns.created_at #{order}"
    elsif sort == "updated_at"
      "campaigns.updated_at #{order}"
    else
      "campaigns.created_at DESC"
    end
  end
end
