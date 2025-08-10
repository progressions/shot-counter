class Api::V2::CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_gamemaster, only: [:create, :update, :destroy]
  before_action :set_campaign, only: [:show, :set, :update]

  def index
    per_page = (params["per_page"] || 15).to_i
    page = (params["page"] || 1).to_i
    selects = [
      "campaigns.id",
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
    query = current_campaign
      .campaigns
      .select(selects)
      .includes(includes)

    # Apply filters
    query = query.where(id: params["id"]) if params["id"].present?
    query = query.where("campaigns.name ILIKE ?", "%#{params['search']}%") if params["search"].present?
    if params["show_all"] == "true"
      query = query.where(active: [true, false, nil])
    else
      query = query.where(active: true)
    end
    # Join associations
    query = query.joins(:characters).where(characters: { id: params[:character_id] }) if params[:character_id].present?
    query = query.joins(:vehicles).where(vehicles: { id: params[:vehicle_id] }) if params[:vehicle_id].present?

    # Cache key
    cache_key = [
      "campaigns/index",
      current_campaign.id,
      sort_order,
      page,
      per_page,
      params["search"],
      params["autocomplete"],
      params["character_id"],
      params["vehicle_id"],
      params["show_all"],
    ].join("/")

    ActiveRecord::Associations::Preloader.new(records: [current_campaign], associations: { user: [:image_attachment, :image_blob] })

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

  def oldindex
    @campaigns = current_user
      .campaigns
      .select(:id, :user_id, :name, :description, :created_at, :updated_at, "LOWER(campaigns.name) AS name_lower")
      .distinct
      .with_attached_image
      .order(Arel.sql(sort_order))

    if params[:search].present?
      @campaigns = @campaigns.where("name ILIKE ?", "%#{params[:search]}%")
    end

    @campaigns = paginate(@campaigns, per_page: (params[:per_page] || 6), page: (params[:page] || 1))

    render json: {
      campaigns: ActiveModelSerializers::SerializableResource.new(@campaigns, each_serializer: CampaignSerializer).serializable_hash,
      meta: pagination_meta(@campaigns),
    }
  end

  def create
    # Check if request is multipart/form-data with a JSON string
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

    campaign_data.slice(:name, :description, :active, :player_ids)

    @campaign = current_user.campaigns.new(campaign_data)

    # Handle image attachment if present
    if params[:image].present?
      @campaign.image.attach(params[:image])
    end

    if @campaign.save
      render json: @campaign, status: :created
    else
      render json: { errors: @campaign.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    # Handle multipart/form-data for updates if present
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
    campaign_data = campaign_data.slice(:name, :description, :active, :faction_id, :player_ids)


    # Handle image attachment if present
    if params[:image].present?
      @campaign.image.purge if @campaign.image.attached? # Remove existing image
      @campaign.image.attach(params[:image])
    end

    if @campaign.update(campaign_data)
      render json: @campaign
    else
      render json: { errors: @campaign.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    if @campaign
      render json: @campaign, serializer: CampaignLiteSerializer, status: :ok
    else
      render status: nil
    end
  end

  def destroy
    # Only a gamemaster can destroy a campaign
    @campaign = current_user.campaigns.find_by(id: params[:id])
    if @campaign
      if @campaign == current_campaign
        render status: 401 and return
      end

      @campaign.destroy!

      render :ok and return
    else
      render status: 404
    end
  end

  def set
    save_current_campaign(@campaign)
    render json: @campaign
  end

  private

  def require_gamemaster
    if !current_user.gamemaster
      render status: 403 and return
    end
  end

  def set_campaign
    if params[:id] == "current"
      @campaign = current_campaign
    else
      @campaign = (current_user.gamemaster && current_user.campaigns.find_by(id: params[:id])) || current_user.player_campaigns.find_by(id: params[:id])
    end
  end

  def campaign_params
    params.require(:campaign).permit(:name, :description, :image, player_ids: [])
  end

  def sort_order
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"

    if sort == "name"
      "LOWER(campaigns.name) #{order}, id"
    elsif sort == "created_at"
      "campaigns.created_at #{order}, id"
    else
      "campaigns.created_at DESC, id"
    end
  end

  def sort_order
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"

    if sort == "name"
      "LOWER(campaigns.name) #{order}"
    elsif sort == "created_at"
      "campaigns.created_at #{order}"
    else
      "campaigns.created_at DESC"
    end
  end
end
