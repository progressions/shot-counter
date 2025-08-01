class Api::V2::VehiclesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_scoped_vehicles
  before_action :set_vehicle, only: [:update, :destroy, :show]

  def index
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"
    per_page = (params["per_page"] || 15).to_i
    page = (params["page"] || 1).to_i

    # Define sort SQL
    if sort == "type"
      sort_sql = Arel.sql("COALESCE(action_values->>'Type', '') #{order}")
    elsif sort == "name"
      sort_sql = Arel.sql("LOWER(vehicles.name) #{order}")
    elsif sort == "created_at"
      sort_sql = Arel.sql("vehicles.created_at #{order}")
    else
      sort_sql = Arel.sql("vehicles.created_at DESC")
    end

    # Base query with minimal fields and preload
    vehicles_query = @scoped_vehicles.select(
      "vehicles.id",
      "vehicles.name",
      "vehicles.image_url",
      "vehicles.faction_id",
      "vehicles.action_values",
      "vehicles.description",
      "vehicles.created_at",
      "vehicles.updated_at",
      "vehicles.task",
      "vehicles.active",
    ).includes(image_attachment: :blob)

    # Apply filters
    vehicles_query = vehicles_query.where(faction_id: params["faction_id"]) if params["faction_id"].present?
    vehicles_query = vehicles_query.where(user_id: params["user_id"]) if params["user_id"].present?
    vehicles_query = vehicles_query.where("vehicles.name ILIKE ?", "%#{params['search']}%") if params["search"].present?
    vehicles_query = vehicles_query.where("action_values->>'Type' = ?", params["type"]) if params["type"].present?
    vehicles_query = vehicles_query.where("action_values->>'Archetype' = ?", params["archetype"]) if params["archetype"].present?

    # Cache key
    cache_key = [
      "vehicles/index",
      current_campaign.id,
      sort,
      order,
      page,
      per_page,
      params["search"],
      params["user_id"],
      params["faction_id"],
      params["type"],
      params["archetype"],
    ].join("/")

    cached_result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      vehicles = vehicles_query.order(sort_sql).page(page).per(per_page)

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
          each_serializer: VehicleSerializer,
          adapter: :attributes
        ).serializable_hash,
        "factions" => ActiveModelSerializers::SerializableResource.new(
          factions,
          each_serializer: FactionLiteSerializer,
          adapter: :attributes
        ).serializable_hash,
        "archetypes" => archetypes,
        "meta" => pagination_meta(vehicles)
      }.to_json
    end

    render json: JSON.parse(cached_result)
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

    vehicle_data = vehicle_data.slice(:name, :description, :active, :vehicle_ids, :party_ids, :site_ids, :juncture_ids, :schtick_ids)

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
    vehicle_data = vehicle_data.slice(:name, :description, :active, :vehicle_ids, :party_ids, :site_ids, :juncture_ids, :schtick_ids)

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
      attunements: { site: { image_attachment: :blob } },
      carries: { weapon: { image_attachment: :blob } },
      vehicle_schticks: :schtick,
      advancements: []
    ).find(params[:id])

    render json: @vehicle
  end

  def destroy
    @vehicle.destroy!
    render :ok
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
    if current_user.gamemaster?
      @scoped_vehicles = current_campaign.vehicles
    else
      @scoped_vehicles = current_user.vehicles
    end
  end

  def vehicle_params
    params.require(:vehicle).permit(:name, :character_id, :faction_id, :defense,
      :impairments, :count, :color, :user_id, :active, :image_url, :image, :task,
      :action_values)
  end

end
