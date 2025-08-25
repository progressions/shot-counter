class Api::V2::PartiesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_party, only: [:show, :update, :destroy, :remove_image]

  def index
    per_page = (params["per_page"] || 15).to_i
    page = (params["page"] || 1).to_i
    selects = [
      "parties.id",
      "parties.name",
      "parties.campaign_id",
      "parties.faction_id",
      "parties.juncture_id",
      "parties.description",
      "parties.created_at",
      "parties.updated_at",
      "parties.active",
    ]
    includes = [
      :image_positions,
      image_attachment: :blob,
      faction: { image_attachment: :blob },
      juncture: { image_attachment: :blob },
      memberships: { character: { image_attachment: :blob } },
      memberships: { vehicle: { image_attachment: :blob } },
    ]
    query = current_campaign
      .parties
      .select(selects)
      .includes(includes)

    # Apply filters
    query = query.where(id: params["id"]) if params["id"].present?
    if params.key?("ids")
      query = params["ids"].blank? ? query.where(id: nil) : query.where(id: params["ids"].split(","))
    end
    query = query.where(params["faction_id"] == "__NONE__" ? "parties.faction_id IS NULL" : "parties.faction_id = ?", params["faction_id"]) if params["faction_id"].present?
    query = query.where(params["juncture_id"] == "__NONE__" ? "parties.juncture_id IS NULL" : "parties.juncture_id = ?", params["juncture_id"]) if params["juncture_id"].present?
    query = query.where("parties.name ILIKE ?", "%#{params['search']}%") if params["search"].present?
    if params["show_all"] == "true"
      query = query.where(active: [true, false, nil])
    else
      query = query.where(active: true)
    end
    # Join associations
    query = query.joins(:memberships).where(memberships: { character_id: params[:character_id] }) if params[:character_id].present?
    query = query.joins(:memberships).where(memberships: { vehicle_id: params[:vehicle_id] }) if params[:vehicle_id].present?

    # Handle cache buster
    if cache_buster_requested?
      clear_resource_cache("parties", current_campaign.id)
      Rails.logger.info "🔄 Cache buster requested for parties"
    end

    # Cache key - includes cache version that changes when any entity is modified
    cache_key = [
      "parties/index",
      current_campaign.id,
      Party.cache_version_for(current_campaign.id),  # Changes when ANY parties is created/updated/deleted
      sort_order,
      page,
      per_page,
      params["party_id"],
      params["search"],
      params["faction_id"],
      params["juncture_id"],
      params["autocomplete"],
      params["character_id"],
      params["show_all"],
    ].join("/")

    ActiveRecord::Associations::Preloader.new(records: [current_campaign], associations: { user: [:image_attachment, :image_blob] })

    # Skip cache if cache buster is requested
    cached_result = if cache_buster_requested?
      Rails.logger.info "⚡ Skipping cache for parties index"
      parties = query.order(Arel.sql(sort_order))
      parties = paginate(parties, per_page: per_page, page: page)
      # Fetch factions
      faction_ids = parties.pluck(:faction_id).uniq.compact
      factions = Faction.where(id: faction_ids)
                        .select("factions.id", "factions.name")
                        .order("LOWER(factions.name) ASC")
      # Archetypes
      {
        "parties" => ActiveModelSerializers::SerializableResource.new(
          parties,
          each_serializer: params[:autocomplete] ? PartyAutocompleteSerializer : PartyIndexSerializer,
          adapter: :attributes
        ).serializable_hash,
        "factions" => ActiveModelSerializers::SerializableResource.new(
          factions,
          each_serializer: FactionLiteSerializer,
          adapter: :attributes
        ).serializable_hash,
        "meta" => pagination_meta(parties)
      }
    else
      Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
        parties = query.order(Arel.sql(sort_order))
        parties = paginate(parties, per_page: per_page, page: page)
        # Fetch factions
        faction_ids = parties.pluck(:faction_id).uniq.compact
        factions = Faction.where(id: faction_ids)
                          .select("factions.id", "factions.name")
                          .order("LOWER(factions.name) ASC")
        # Archetypes
        {
          "parties" => ActiveModelSerializers::SerializableResource.new(
            parties,
            each_serializer: params[:autocomplete] ? PartyAutocompleteSerializer : PartyIndexSerializer,
            adapter: :attributes
          ).serializable_hash,
          "factions" => ActiveModelSerializers::SerializableResource.new(
            factions,
            each_serializer: FactionLiteSerializer,
            adapter: :attributes
          ).serializable_hash,
          "meta" => pagination_meta(parties)
        }
      end
    end
    render json: cached_result
  end

  def show
    render json: @party, serializer: PartySerializer, status: :ok
  end

  def create
    # Check if request is multipart/form-data with a JSON string
    if params[:party].present? && params[:party].is_a?(String)
      begin
        party_data = JSON.parse(params[:party]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid party data format" }, status: :bad_request
        return
      end
    else
      party_data = party_params.to_h.symbolize_keys
    end

    party_data.slice(:name, :description, :active, :faction_id, :juncture_id, :character_ids, :vehicle_ids)

    @party = current_campaign.parties.new(party_data)

    # Handle image attachment if present
    if params[:image].present?
      @party.image.attach(params[:image])
    end

    if @party.save
      # Clear parties index cache after creating a new party
      clear_parties_cache
      render json: @party, serializer: PartySerializer, status: :created
    else
      render json: { errors: @party.errors }, status: :unprocessable_entity
    end
  end

  def update
    @party = current_campaign.parties.find(params[:id])

    # Handle multipart/form-data for updates if present
    if params[:party].present? && params[:party].is_a?(String)
      begin
        party_data = JSON.parse(params[:party]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid party data format" }, status: :bad_request
        return
      end
    else
      party_data = party_params.to_h.symbolize_keys
    end
    party_data = party_data.slice(:name, :description, :active, :faction_id, :character_ids, :vehicle_ids, :juncture_id)

    # Handle image attachment if present
    if params[:image].present?
      @party.image.purge if @party.image.attached? # Remove existing image
      @party.image.attach(params[:image])
    end

    if @party.update(party_data)
      # Clear parties index cache after updating a party
      clear_parties_cache
      render json: @party.reload
    else
      render json: { errors: @party.errors }, status: :unprocessable_entity
    end
  end

  def add_to_fight
    @party = current_campaign.parties.find(params[:party_id])
    @fight = current_campaign.fights.find(params[:fight_id])

    # Allow multiple instances - always create new shots regardless of existing ones
    # Characters/vehicles start hidden (shot: nil) when added to fight
    @party.characters.each do |character|
      @fight.shots.create!(character: character, shot: nil)
    end

    @party.vehicles.each do |vehicle|
      @fight.shots.create!(vehicle: vehicle, shot: nil)
    end

    # Broadcast fight update for real-time changes
    @fight.send(:broadcast_update)

    render json: @party, serializer: PartySerializer
  end

  def destroy
    if @party.membership_ids.any? && !params[:force]
      render json: { errors: { memberships: true  } }, status: 400 and return
    end

    if @party.membership_ids.any? && params[:force]
      @party.memberships.destroy_all
    end

    if @party.destroy!
      render :ok
    else
      render json: { errors: @party.errors }, status: 400
    end
  end

  def remove_image
    @party.image.purge

    if @party.save
      render json: @party
    else
      render @party.errors, status: 400
    end
  end

  private

  def clear_parties_cache
    # Clear all parties index cache entries for this campaign
    Rails.cache.delete_matched("parties/index/#{current_campaign.id}/*")
    Rails.logger.info "🗑️ Cleared parties cache for campaign #{current_campaign.id}"
  end

  def set_party
    @party = current_campaign.parties.find(params[:id])
  end

  def party_params
    params.require(:party).permit(:name, :description, :faction_id, :active, :image, :juncture_id, vehicle_ids: [], character_ids: [])
  end

  def sort_order
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"

    if sort == "name"
      "LOWER(parties.name) #{order}"
    elsif sort == "created_at"
      "parties.created_at #{order}"
    elsif sort == "updated_at"
      "parties.updated_at #{order}"
    else
      "parties.created_at DESC"
    end
  end
end
