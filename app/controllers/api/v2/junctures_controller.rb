class Api::V2::JuncturesController < ApplicationController
  include VisibilityFilterable
  
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    per_page = (params["per_page"] || 15).to_i
    page = (params["page"] || 1).to_i
    selects = [
      "junctures.id",
      "junctures.name",
      "junctures.campaign_id",
      "junctures.faction_id",
      "junctures.description",
      "junctures.created_at",
      "junctures.updated_at",
      "junctures.active",
    ]
    includes = [
      :image_positions,
      image_attachment: :blob,
      characters: { image_attachment: :blob },
      vehicles: { image_attachment: :blob },
    ]
    query = current_campaign
      .junctures
      .select(selects)
      .includes(includes)

    # Apply filters
    query = query.where(id: params["id"]) if params["id"].present?
    query = apply_ids_filter(query, params["ids"]) if params.key?("ids")
    query = query.where("junctures.name ILIKE ?", "%#{params['search']}%") if params["search"].present?
    query = query.where(params["faction_id"] == "__NONE__" ? "junctures.faction_id IS NULL" : "junctures.faction_id = ?", params["faction_id"]) if params["faction_id"].present?

    query = query.where(apply_visibility_filter)
    # Join associations
    query = query.joins(:characters).where(characters: { id: params[:character_id] }) if params[:character_id].present?
    query = query.joins(:vehicles).where(vehicles: { id: params[:vehicle_id] }) if params[:vehicle_id].present?

    # Handle cache buster
    if cache_buster_requested?
      clear_resource_cache("junctures", current_campaign.id)
      Rails.logger.info "🔄 Cache buster requested for junctures"
    end

    # Cache key - includes cache version that changes when any entity is modified
    cache_key = [
      "junctures/index",
      current_campaign.id,
      Juncture.cache_version_for(current_campaign.id),  # Changes when ANY junctures is created/updated/deleted
      sort_order,
      page,
      per_page,
      params["id"],
      format_ids_for_cache(params["ids"]),
      params["search"],
      params["juncture_id"],
      params["autocomplete"],
      params["character_id"],
      params["visibility"],
      params["show_hidden"],
    Time.now.to_i # TEMPORARY: Bust cache every request
  ].join("/")

    ActiveRecord::Associations::Preloader.new(records: [current_campaign], associations: { user: [:image_attachment, :image_blob] })

    # Skip cache if cache buster is requested
    cached_result = if cache_buster_requested?
      Rails.logger.info "⚡ Skipping cache for junctures index"
      junctures = query.order(Arel.sql(sort_order))
      junctures = paginate(junctures, per_page: per_page, page: page)
      # Fetch factions
      faction_ids = junctures.pluck(:faction_id).uniq.compact
      factions = Faction.where(id: faction_ids)
                        .select("factions.id", "factions.name")
                        .order("LOWER(factions.name) ASC")

      {
        "junctures" => ActiveModelSerializers::SerializableResource.new(
          junctures,
          each_serializer: params[:autocomplete] ? JunctureAutocompleteSerializer : JunctureIndexSerializer,
          adapter: :attributes
        ).serializable_hash,
        "factions" => ActiveModelSerializers::SerializableResource.new(
          factions,
          each_serializer: FactionLiteSerializer,
          adapter: :attributes
        ).serializable_hash,
        "meta" => pagination_meta(junctures)
      }
    else
      Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
        junctures = query.order(Arel.sql(sort_order))
        junctures = paginate(junctures, per_page: per_page, page: page)
        # Fetch factions
        faction_ids = junctures.pluck(:faction_id).uniq.compact
        factions = Faction.where(id: faction_ids)
                          .select("factions.id", "factions.name")
                          .order("LOWER(factions.name) ASC")

        {
          "junctures" => ActiveModelSerializers::SerializableResource.new(
            junctures,
            each_serializer: params[:autocomplete] ? JunctureAutocompleteSerializer : JunctureIndexSerializer,
            adapter: :attributes
          ).serializable_hash,
          "factions" => ActiveModelSerializers::SerializableResource.new(
            factions,
            each_serializer: FactionLiteSerializer,
            adapter: :attributes
          ).serializable_hash,
          "meta" => pagination_meta(junctures)
        }
      end
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

    juncture_data.slice(:name, :description, :active, :faction_id, :character_ids, :vehicle_ids)

    @juncture = current_campaign.junctures.new(juncture_data)

    # Handle image attachment if present
    if params[:image].present?
      @juncture.image.attach(params[:image])
    end

    if @juncture.save
      render json: @juncture, status: :created
    else
      render json: { errors: @juncture.errors }, status: :unprocessable_entity
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
    juncture_data = juncture_data.slice(:name, :description, :active, :faction_id, :character_ids, :vehicle_ids)

    # Handle image attachment if present
    if params[:image].present?
      @juncture.image.purge if @juncture.image.attached? # Remove existing image
      @juncture.image.attach(params[:image])
    end

    if @juncture.update(juncture_data)
      render json: @juncture.reload
    else
      render json: { errors: @juncture.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @juncture = current_campaign.junctures.find(params[:id])
    service = JunctureDeletionService.new
    result = service.delete(@juncture, force: params[:force].present?)
    handle_deletion_result(result)
  end

  def remove_image
    @juncture = current_campaign.junctures.find(params[:id])
    @juncture.image.purge

    if @juncture.save
      render json: @juncture
    else
      render json: { errors: @juncture.errors }, status: :unprocessable_entity
    end
  end

  private

  def juncture_params
    params.require(:juncture).permit(:name, :description, :active, :image, :faction_id, character_ids: [], vehicle_ids: [])
  end

  def sort_order
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"
    if sort == "name"
      "LOWER(junctures.name) #{order}, junctures.id"
    elsif sort == "created_at"
      "junctures.created_at #{order}, junctures.id"
    elsif sort == "updated_at"
      "junctures.updated_at #{order}, junctures.id"
    else
      "junctures.created_at DESC, junctures.id"
    end
  end
end
