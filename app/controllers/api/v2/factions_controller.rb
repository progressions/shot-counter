class Api::V2::FactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    per_page = (params["per_page"] || 15).to_i
    page = (params["page"] || 1).to_i
    selects = [
      "factions.id",
      "factions.name",
      "factions.campaign_id",
      "factions.description",
      "factions.created_at",
      "factions.updated_at",
      "factions.active",
    ]
    includes = [
      :image_positions,
      image_attachment: :blob,
      junctures: { image_attachment: :blob },
      characters: { image_attachment: :blob },
      vehicles: { image_attachment: :blob },
    ]
    query = current_campaign
      .factions
      .select(selects)
      .includes(includes)

    # Apply filters
    query = query.where(id: params["id"]) if params["id"].present?
    if params.key?("ids")
      query = params["ids"].blank? ? query.where(id: nil) : query.where(id: params["ids"].split(","))
    end
    query = query.where("factions.name ILIKE ?", "%#{params['search']}%") if params["search"].present?
    if params["show_all"] == "true"
      query = query.where(active: [true, false, nil])
    else
      query = query.where(active: true)
    end
    # Join associations
    query = query.joins(:characters).where(characters: { id: params[:character_id] }) if params[:character_id].present?
    query = query.joins(:vehicles).where(vehicles: { id: params[:vehicle_id] }) if params[:vehicle_id].present?
    query = query.joins(:junctures).where(junctures: { id: params[:juncture_id] }) if params[:juncture_id].present?

    # Cache key
    cache_key = [
      "factions/index",
      current_campaign.id,
      sort_order,
      page,
      per_page,
      params["search"],
      params["juncture_id"],
      params["autocomplete"],
      params["character_id"],
      params["vehicle_id"],
      params["show_all"],
    ].join("/")

    ActiveRecord::Associations::Preloader.new(records: [current_campaign], associations: { user: [:image_attachment, :image_blob] })

    cached_result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      factions = query.order(Arel.sql(sort_order))
      factions = paginate(factions, per_page: per_page, page: page)

      {
        "factions" => ActiveModelSerializers::SerializableResource.new(
          factions,
          each_serializer: params[:autocomplete] ? FactionAutocompleteSerializer : FactionIndexSerializer,
          adapter: :attributes
        ).serializable_hash,
        "meta" => pagination_meta(factions)
      }
    end
    render json: cached_result
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

    faction_data = faction_data.slice(:name, :description, :character_ids, :party_ids, :site_ids, :juncture_ids, :vehicle_ids)

    @faction = current_campaign.factions.new(faction_data)

    # Handle image attachment if present
    if params[:image].present?
      @faction.image.attach(params[:image])
    end

    if @faction.save
      # Clear factions index cache after creating a new faction
      clear_factions_cache
      render json: @faction, status: :created
    else
      render json: { errors: @faction.errors }, status: :unprocessable_entity
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
    faction_data = faction_data.slice(:name, :description, :character_ids, :party_ids, :site_ids, :juncture_ids, :vehicle_ids)

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
      # Clear factions index cache after updating a faction
      clear_factions_cache
      render json: @faction.reload
    else
      render json: { errors: @faction.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @faction = current_campaign.factions.find(params[:id])
    if @faction.character_ids.any? && !params[:force]
      render json: { errors: { characters: true } }, status: 400 and return
    end
    if @faction.vehicle_ids.any? && !params[:force]
      render json: { errors: { vehicles: true } }, status: 400 and return
    end
    if params[:force]
      @faction.characters.update_all(faction_id: nil)
      @faction.vehicles.update_all(faction_id: nil)
      @faction.parties.update_all(faction_id: nil)
      @faction.sites.update_all(faction_id: nil)
      @faction.junctures.update_all(faction_id: nil)
    end
    if @faction.destroy!
      render :ok
    else
      render json: { errors: @faction.errors }, status: 400
    end
  end

  def remove_image
    faction = current_campaign.factions.find(params[:id])
    faction.image.purge if faction.image.attached?
    render json: faction
  end

  private

  def clear_factions_cache
    # Clear all factions index cache entries for this campaign
    Rails.cache.delete_matched("factions/index/#{current_campaign.id}/*")
    Rails.logger.info "🗑️ Cleared factions cache for campaign #{current_campaign.id}"
  end

  def faction_params
    params.require(:faction).permit(:name, :description, :image, character_ids: [], party_ids: [], site_ids: [], juncture_ids: [], vehicle_ids: [])
  end

  def sort_order
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"

    if sort == "name"
      "LOWER(factions.name) #{order}"
    elsif sort == "created_at"
      "factions.created_at #{order}"
    else
      "factions.created_at DESC"
    end
  end
end
