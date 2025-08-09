class Api::V2::VehiclesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_scoped_vehicles
  before_action :set_vehicle, only: [:update, :destroy]

  def index
    per_page = (params["per_page"] || 15).to_i
    page = (params["page"] || 1).to_i

    # Base query with minimal fields and preload
    query = @scoped_vehicles
      .select(
        "vehicles.id",
        "vehicles.name",
        "vehicles.image_url",
        "vehicles.faction_id",
        "vehicles.action_values",
        "vehicles.description",
        "vehicles.created_at",
        "vehicles.updated_at",
      ).includes(
        :image_positions,
        image_attachment: :blob,
      )

    # Apply filters
    query = query.where(faction_id: params["faction_id"]) if params["faction_id"].present?
    query = query.where(juncture_id: params["juncture_id"]) if params["juncture_id"].present?
    query = query.where(user_id: params["user_id"]) if params["user_id"].present?
    query = query.where("vehicles.name ILIKE ?", "%#{params['search']}%") if params["search"].present?
    query = query.where(id: params["id"]) if params["id"].present?
    query = query.where(id: params["ids"].split(",")) if params["ids"].present?
    query = query.where("action_values->>'Type' = ?", params["type"]) if params["type"].present?
    query = query.where("action_values->>'Archetype' = ?", params["archetype"]) if params["archetype"].present?
    if params["show_all"] == "true"
      query = query.where(active: [true, false, nil])
    else
      query = query.where(active: true)
    end

    # Join associations
    query = query.joins(:memberships).where(memberships: { party_id: params[:party_id] }) if params[:party_id].present?
    query = query.joins(:shots).where(shots: { fight_id: params[:fight_id] }) if params[:fight_id].present?

    # Cache key
    cache_key = [
      "vehicles/index",
      current_campaign.id,
      sort_order,
      page,
      per_page,
      params["site_id"],
      params["fight_id"],
      params["party_id"],
      params["search"],
      params["user_id"],
      params["faction_id"],
      params["autocomplete"],
      params["juncture_id"],
      params["type"],
      params["archetype"],
    ].join("/")

    cached_result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      vehicles = query
        .order(Arel.sql(sort_order))

      vehicles = paginate(vehicles, per_page: per_page, page: page)

      # Fetch factions
      faction_ids = vehicles.pluck(:faction_id).uniq.compact
      factions = Faction.where(id: faction_ids)
                        .select("factions.id", "factions.name")
                        .order("LOWER(factions.name) ASC")

      # Archetypes
      archetypes = vehicles.map { |c| c.action_values["Archetype"] }.compact.uniq.sort

      {
        "vehicles" => ActiveModelSerializers::SerializableResource.new(
          vehicles,
          each_serializer: params[:autocomplete] ? VehicleLiteSerializer : VehicleIndexSerializer,
          adapter: :attributes
        ).serializable_hash,
        "factions" => ActiveModelSerializers::SerializableResource.new(
          factions,
          each_serializer: FactionLiteSerializer,
          adapter: :attributes
        ).serializable_hash,
        "archetypes" => archetypes,
        "meta" => pagination_meta(vehicles)
      }
    end

    render json: cached_result
  end

  def autocomplete
    vehicles = current_campaign.vehicles.active
      .select("vehicles.id", "vehicles.name", "vehicles.faction_id", "vehicles.action_values", "vehicles.description")

    if params["faction_id"].present?
      vehicles = vehicles.where(faction_id: params["faction_id"])
    end

    if params["type"].present?
      vehicles = vehicles.where("action_values ->> 'Type' = ?", params["type"])
    end

    if params["archetype"].present?
      vehicles = vehicles.where("action_values ->> 'Archetype' = ?", params["archetype"])
    end

    vehicles = vehicles.order("LOWER(vehicles.name) #{params['order'] || 'asc'}")
      .limit(params["per_page"] || 75)
      .offset((params["page"]&.to_i || 0) * (params["per_page"]&.to_i || 75))

    # Get unique factions based on matching vehicles
    faction_ids = vehicles.pluck(:faction_id).uniq.compact
    factions = Faction.where(id: faction_ids)
                      .select("factions.id", "factions.name")
                      .order("LOWER(factions.name) ASC")

    archetypes = vehicles.map { |c| c.action_values["Archetype"] }.compact.uniq.sort

    render json: {
      vehicles: ActiveModelSerializers::SerializableResource.new(
        vehicles,
        each_serializer: VehicleAutocompleteSerializer,
        adapter: :attributes
      ),
      factions: ActiveModelSerializers::SerializableResource.new(
        factions,
        each_serializer: FactionAutocompleteSerializer,
        adapter: :attributes
      ),
      archetypes: archetypes
    }
  end

  def create
    # Check if request is multipart/form-data with a JSON string
    if params[:vehicle].present? && params[:vehicle].is_a?(String)
      begin
        vehicle_data = JSON.parse(params[:vehicle]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid vehicle data format" }, status: :bad_request
        return
      end
    else
      vehicle_data = vehicle_params.to_h.symbolize_keys
    end

    vehicle_data = vehicle_data.slice(:name, :description, :active, :vehicle_ids, :faction_id, :party_ids, :action_values)

    @vehicle = current_campaign.vehicles.new(vehicle_data)

    # Handle image attachment if present
    if params[:image].present?
      @vehicle.image.attach(params[:image])
    end

    if @vehicle.save
      render json: @vehicle, status: :created
    else
      render json: { errors: @vehicle.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @vehicle = current_campaign.vehicles.find(params[:id])

    # Handle multipart/form-data for updates if present
    if params[:vehicle].present? && params[:vehicle].is_a?(String)
      begin
        vehicle_data = JSON.parse(params[:vehicle]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid vehicle data format" }, status: :bad_request
        return
      end
    else
      vehicle_data = vehicle_params.to_h.symbolize_keys
    end
    vehicle_data = vehicle_data.slice(:name, :description, :active, :vehicle_ids, :party_ids, :site_ids, :juncture_ids, :schtick_ids, :action_values)

    # Handle image attachment if present
    if params[:image].present?
      begin
        @vehicle.image.purge if @vehicle.image.attached? # Remove existing image
        @vehicle.image.attach(params[:image])
      rescue StandardError => e
        Rails.logger.error("Error uploading to ImageKit")
      end
    end

    if @vehicle.update(vehicle_data)
      Rails.cache.delete_matched("vehicles/#{current_campaign.id}/*")

      render json: @vehicle
    else
      render json: { errors: @vehicle.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    @vehicle = current_campaign.vehicles.includes(
      user: { image_attachment: :blob },
      faction: { image_attachment: :blob },
      image_attachment: :blob,
    ).find(params[:id])

    render json: @vehicle
  end

  def destroy
    if @vehicle.carry_ids.any? && !params[:force]
      render json: { errors: { carries: true  } }, status: 400 and return
    end

    if @vehicle.carry_ids.any? && params[:force]
      carry.where(id: @vehicle.carry_ids).destroy_all
    end

    if @vehicle.destroy!
      render :ok
    else
      render json: { errors: @vehicle.errors }, status: 400
    end
  end

  def remove_image
    @vehicle.image.purge

    if @vehicle.save
      render json: @vehicle
    else
      render @vehicle.errors, status: 400
    end
  end

  private

  def set_vehicle
    @vehicle = @scoped_vehicles.find(params[:id])
  end

  def set_scoped_vehicles
    @scoped_vehicles = current_campaign.vehicles
  end

  def vehicle_params
    params.require(:vehicle).permit(:name, :character_id, :faction_id, :defense,
      :impairments, :count, :color, :user_id, :active, :image_url, :image,
      :action_values)
  end

  def sort_order
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"

    if sort == "type"
      "COALESCE(action_values->>'Type', '') #{order}"
    elsif sort == "archetype"
      "COALESCE(action_values->>'Archetype', '') #{order}"
    elsif sort == "name"
      "LOWER(vehicles.name) #{order}"
    elsif sort == "created_at"
      "vehicles.created_at #{order}"
    elsif sort == "update_at"
      "vehicles.update_at #{order}"
    else
      "vehicles.created_at DESC"
    end
  end
end
