class Api::V1::JuncturesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    sort = params[:sort] || "created_at"
    order = params[:order] || "DESC"

    @junctures = current_campaign.junctures.order(sort => order)

    Rails.logger.info("params[:active]: #{params[:active]}")

    if params[:id].present?
      @junctures = @junctures.where(id: params[:id])
    end
    if params[:hidden] == "true" && current_user.gamemaster?
      @junctures = @junctures.where(active: [true, false])
    else
      @junctures = @junctures.where(active: true)
    end
    if params[:search].present?
      @junctures = @junctures.where("name ILIKE ?", "%#{params[:search]}%")
    end
    if params[:faction_id].present?
      @junctures = @junctures.where(faction_id: params[:faction_id])
    end
    if params[:character_id].present?
      @character = current_campaign.characters.find(params[:character_id])
      @junctures = @junctures.where.not(id: @character.juncture_id)
    end

    @junctures = paginate(@junctures, per_page: (params[:per_page] || 10), page: (params[:page] || 1))

    render json: {
      junctures: ActiveModelSerializers::SerializableResource.new(@junctures, each_serializer: JunctureSerializer).serializable_hash,
      factions: ActiveModelSerializers::SerializableResource.new(current_campaign.factions, each_serializer: FactionSerializer).serializable_hash,
      meta: pagination_meta(@junctures),
    }
  end

  def show
    render json: current_campaign.junctures.find(params[:id])
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
      binding.pry
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
    juncture_data = juncture_data.slice(:name, :description, :active, :faction_id)

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
    params.require(:juncture).permit(:name, :description, :active, :image, :faction_id)
  end
end
