class Api::V2::JuncturesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    @junctures = current_campaign
      .junctures
      .distinct
      .with_attached_image

    if params[:id].present?
      @junctures = @junctures.where(id: params[:id])
    end
    if params[:search].present?
      @junctures = @junctures.where("name ILIKE ?", "%#{params[:search]}%")
    end
    if params[:faction_id].present?
      @junctures = @junctures.where(faction_id: params[:faction_id])
    end
    if params[:character_id].present?
      @junctures = @junctures.joins(:attunements).where(attunements: { id: params[:character_id] })
    end
    if params[:user_id].present?
      @junctures = @junctures.joins(:characters).where(characters: { user_id: params[:user_id] })
    end

    cache_key = [
      "junctures/index",
      current_campaign.id,
      sort_order,
      params[:page],
      params[:per_page],
      params[:id],
      params[:search],
      params[:user_id],
      params[:faction_id],
      params[:character_id],
    ].join("/")

    @factions = current_campaign.factions.joins(:junctures).where(junctures: @junctures).order("factions.name").distinct

    @junctures = @junctures
      .select(:id, :name, :description, :campaign_id, :faction_id, :created_at, :updated_at)
      .includes(
        { faction: [:image_attachment, :image_blob] },
        :image_positions,
      )
      .order(Arel.sql(sort_order))

    cached_result = Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      @junctures = paginate(@junctures, per_page: (params[:per_page] || 10), page: (params[:page] || 1))

      {
        junctures: ActiveModelSerializers::SerializableResource.new(@junctures, each_serializer: JunctureIndexSerializer).serializable_hash,
        factions: ActiveModelSerializers::SerializableResource.new(@factions, each_serializer: FactionLiteSerializer).serializable_hash,
        meta: pagination_meta(@junctures),
      }
    end

    render json: cached_result
  end

  def show
    @juncture = current_campaign.junctures.find(params[:id])
    render json: @juncture
  end

  def create
    # Check if request is multipart/form-data with a JSON string
    if params[:juncture].present? && params[:juncture].is_a?(String)
      begin
        juncture_data = JSON.parse(params[:juncture]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid juncture data format" }, status: :bad_request
        return
      end
    else
      juncture_data = juncture_params.to_h.symbolize_keys
    end

    juncture_data.slice(:name, :description, :active, :faction_id)

    @juncture = current_campaign.junctures.new(juncture_data)

    # Handle image attachment if present
    if params[:image].present?
      @juncture.image.attach(params[:image])
    end

    if @juncture.save
      render json: @juncture, status: :created
    else
      render json: { errors: @juncture.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @juncture = current_campaign.junctures.find(params[:id])

    # Handle multipart/form-data for updates if present
    if params[:juncture].present? && params[:juncture].is_a?(String)
      begin
        juncture_data = JSON.parse(params[:juncture]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid juncture data format" }, status: :bad_request
        return
      end
    else
      juncture_data = juncture_params.to_h.symbolize_keys
    end
    juncture_data = juncture_data.slice(:name, :description, :active, :faction_id, :character_ids)

    # Handle image attachment if present
    if params[:image].present?
      @juncture.image.purge if @juncture.image.attached? # Remove existing image
      @juncture.image.attach(params[:image])
    end

    if @juncture.update(juncture_data)
      render json: @juncture
    else
      render json: { errors: @juncture.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    juncture = current_campaign.junctures.find(params[:id])
    juncture.destroy

    head :no_content
  end

  def remove_image
    @juncture = current_campaign.junctures.find(params[:id])
    @juncture.image.purge

    if @juncture.save
      render json: @juncture
    else
      render json: { errors: @juncture.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def juncture_params
    params.require(:juncture).permit(:name, :description, :active, :image, :faction_id, :character_ids)
  end

  def sort_order
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"
    if sort == "name"
      "LOWER(junctures.name) #{order}, junctures.id"
    elsif sort == "created_at"
      "junctures.created_at #{order}, junctures.id"
    else
      "junctures.created_at DESC, junctures.id"
    end
  end
end
