class Api::V2::CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_gamemaster, only: [:create, :update, :destroy]
  before_action :set_campaign, only: [:show, :set, :update]

  def index
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"

    if sort == "name"
      sort = Arel.sql("LOWER(campaigns.name) #{order}")
    elsif sort == "created_at"
      sort = Arel.sql("campaigns.created_at #{order}")
    else
      sort = Arel.sql("campaigns.created_at DESC")
    end

    @campaigns = current_user.campaigns.includes(:image_attachment).order(sort)

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
end
