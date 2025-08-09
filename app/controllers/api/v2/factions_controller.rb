class Api::V2::FactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"

    if sort == "name"
      sort = Arel.sql("LOWER(factions.name) #{order}")
    elsif sort == "created_at"
      sort = Arel.sql("factions.created_at #{order}")
    else
      sort = Arel.sql("factions.created_at DESC")
    end

    @factions = current_campaign
      .factions
      .distinct
      .with_attached_image
      .order(sort)

    if params[:id].present?
      @factions = @factions.where(id: params[:id])
    end
    if params[:show_all] == "true" && current_user.gamemaster?
      @factions = @factions.where(active: [true, false])
    else
      @factions = @factions.where(active: true)
    end
    if params[:search].present?
      @factions = @factions.where("name ILIKE ?", "%#{params[:search]}%")
    end
    if params[:character_id].present?
      @factions = @factions.joins(:characters).where(characters: { id: params[:character_id] })
    end

    @factions = paginate(@factions, per_page: (params[:per_page] || 10), page: (params[:page] || 1))

    if params[:autocomplete]
      render json: {
        factions: ActiveModelSerializers::SerializableResource.new(@factions, each_serializer: FactionAutocompleteSerializer).serializable_hash,
        meta: pagination_meta(@factions)
      }
    else
      render json: {
        factions: ActiveModelSerializers::SerializableResource.new(@factions, each_serializer: FactionSerializer).serializable_hash,
        meta: pagination_meta(@factions)
      }
    end
  end

  def show
    @faction = current_campaign.factions.includes(:image_attachment).find(params[:id])
    render json: @faction, serializer: FactionSerializer
  end

  def create
    # Check if request is multipart/form-data with a JSON string
    if params[:faction].present? && params[:faction].is_a?(String)
      begin
        faction_data = JSON.parse(params[:faction]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid faction data format" }, status: :bad_request
        return
      end
    else
      faction_data = faction_params.to_h.symbolize_keys
    end

    faction_data = faction_data.slice(:name, :description, :active, :character_ids, :party_ids, :site_ids, :juncture_ids)

    @faction = current_campaign.factions.new(faction_data)

    # Handle image attachment if present
    if params[:image].present?
      @faction.image.attach(params[:image])
    end

    if @faction.save
      render json: @faction, status: :created
    else
      render json: { errors: @faction.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @faction = current_campaign.factions.find(params[:id])

    # Handle multipart/form-data for updates if present
    if params[:faction].present? && params[:faction].is_a?(String)
      begin
        faction_data = JSON.parse(params[:faction]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid faction data format" }, status: :bad_request
        return
      end
    else
      faction_data = faction_params.to_h.symbolize_keys
    end
    faction_data = faction_data.slice(:name, :description, :active, :character_ids, :party_ids, :site_ids, :juncture_ids)

    # Handle image attachment if present
    if params[:image].present?
      begin
        @faction.image.purge if @faction.image.attached? # Remove existing image
        @faction.image.attach(params[:image])
      rescue StandardError => e
        Rails.logger.error("Error uploading to ImageKit")
      end
    end

    if @faction.update(faction_data)
      render json: @faction
    else
      render json: { errors: @faction.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    faction = current_campaign.factions.find(params[:id])
    faction.destroy
    head :ok
  end

  def remove_image
    faction = current_campaign.factions.find(params[:id])
    faction.image.purge if faction.image.attached?
    render json: faction
  end

  private

  def faction_params
    params.require(:faction).permit(:name, :description, :active, :image, character_ids: [], party_ids: [], site_ids: [], juncture_ids: [])
  end
end
