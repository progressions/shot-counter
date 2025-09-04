class Api::V2::FightsController < ApplicationController
  include VisibilityFilterable
  
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_fight, only: [:show, :update, :destroy, :touch]

  def index
  per_page = (params["per_page"] || 15).to_i
  page = (params["page"] || 1).to_i
  selects = [
    "fights.id",
    "fights.name",
    "fights.description",
    "fights.campaign_id",
    "fights.started_at",
    "fights.ended_at",
    "fights.created_at",
    "fights.updated_at",
    "fights.active",
    "fights.season",
    "fights.session",
    "LOWER(fights.name) AS name_lower",
  ]
  query = current_campaign
    .fights
    .select(selects)
    .eager_load(
      :image_positions, # Needed for FightIndexLiteSerializer
      image_attachment: :blob, # Needed for image_url
      shots: [:character, :vehicle] # No image_attachment
    )

  # Apply filters
  search_param = params["search"].presence
  query = query.where("fights.name ILIKE ?", "%#{search_param}%") if search_param
  query = query.where(apply_visibility_filter)
  query = query.where(id: params["id"]) if params["id"].present?
  query = apply_ids_filter(query, params["ids"]) if params.key?("ids")
  query = query.where(started_at: nil) if params["status"] == "Unstarted"
  query = query.where.not(started_at: nil).where(ended_at: nil) if params["status"] == "Started"
  query = query.where.not(started_at: nil).where.not(ended_at: nil) if params["status"] == "Ended"
  query = query.where(params["season"] == "__NONE__" ? "fights.season IS NULL" : "fights.season = ?", params["season"]) if params["season"].present?
  query = query.where(params["session"] == "__NONE__" ? "fights.session IS NULL" : "fights.session = ?", params["session"]) if params["session"].present?
  query = query.joins(:shots).where(shots: { character_id: params[:character_id] }) if params[:character_id].present?
  query = query.joins(:shots).where(shots: { vehicle_id: params[:vehicle_id] }) if params[:vehicle_id].present?
  query = query.joins(:shots).joins("INNER JOIN characters ON shots.character_id = characters.id").where(characters: { user_id: params[:user_id] }) if params[:user_id].present?

  # Handle cache buster
  if cache_buster_requested?
    clear_resource_cache("fights", current_campaign.id)
    Rails.logger.info "🔄 Cache buster requested for fights"
  end

  # Cache key - includes cache version that changes whenever any fight is modified
  cache_key = [
    "fights/index",
    current_campaign.id,
    Fight.cache_version_for(current_campaign.id),  # Changes when ANY fight is created/updated/deleted
    sort_order,
    page,
    per_page,
      params["id"],
      format_ids_for_cache(params["ids"]),
    search_param,
    params["visibility"],
    params["show_hidden"],
    params["character_id"],
    params["vehicle_id"],
    params["user_id"],
    params["unstarted"],
    params["unended"],
    params["ended"],
    params["season"],
    params["session"],
    params["autocomplete"],
  ].join("/")
  # Skip cache if cache buster is requested
  cached_result = if cache_buster_requested?
    Rails.logger.info "⚡ Skipping cache for fights index"
    fights = query.order(Arel.sql(sort_order)).distinct
    seasons = query.select("fights.season").distinct.pluck(:season).compact.uniq
    fights = paginate(fights, per_page: per_page, page: page)
    {
      "fights" => ActiveModelSerializers::SerializableResource.new(
        fights,
        each_serializer: params[:autocomplete] ? FightLiteSerializer : FightIndexLiteSerializer,
        adapter: :attributes
      ).serializable_hash,
      "seasons" => seasons,
      "meta" => pagination_meta(fights)
    }
  else
    Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      fights = query.order(Arel.sql(sort_order)).distinct
      seasons = query.select("fights.season").distinct.pluck(:season).compact.uniq
      fights = paginate(fights, per_page: per_page, page: page)
      {
        "fights" => ActiveModelSerializers::SerializableResource.new(
          fights,
          each_serializer: params[:autocomplete] ? FightLiteSerializer : FightIndexLiteSerializer,
          adapter: :attributes
        ).serializable_hash,
        "seasons" => seasons,
        "meta" => pagination_meta(fights)
      }
    end
  end
  render json: cached_result
end

  def show
    render json: @fight, serializer: FightSerializer, status: :ok
  end

  def create
    if params[:fight].present? && params[:fight].is_a?(String)
      begin
        fight_data = JSON.parse(params[:fight]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid fight data format" }, status: :bad_request
        return
      end
    else
      fight_data = fight_params.to_h.symbolize_keys
    end
    fight_data = fight_data.slice(:name, :sequence, :active, :archived, :description, :image, :character_ids, :vehicle_ids, :started_at, :ended_at, :season, :session)
    @fight = current_campaign.fights.new(fight_data)
    if params[:image].present?
      @fight.image.attach(params[:image])
    end
    if @fight.save
      render json: @fight, serializer: FightSerializer, status: :created
    else
      render json: { errors: @fight.errors }, status: :unprocessable_entity
    end
  end

  def update
    @fight = current_campaign.fights.find(params[:id])
    if params[:fight].present? && params[:fight].is_a?(String)
      begin
        fight_data = JSON.parse(params[:fight]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid fight data format" }, status: :bad_request
        return
      end
    else
      fight_data = fight_params.to_h.symbolize_keys
    end
    fight_data = fight_data.slice(:name, :sequence, :active, :archived, :description, :character_ids, :vehicle_ids, :started_at, :ended_at, :season, :session)
    if params[:image].present?
      @fight.image.purge if @fight.image.attached?
      @fight.image.attach(params[:image])
    end
    if @fight.update(fight_data)
      render json: @fight.reload, serializer: FightSerializer, status: :ok
    else
      render json: { errors: @fight.errors }, status: :unprocessable_entity
    end
  end

  def touch
    @fight.send(:broadcast_update)
    render json: @fight
  end

  def destroy
    service = FightDeletionService.new
    result = service.delete(@fight, force: params[:force].present?)
    handle_deletion_result(result)
  end

  def end_fight
    @fight = current_campaign.fights.find(params[:id])
    
    # Only gamemaster can end fights
    unless current_user.gamemaster?
      render json: { error: "Only the gamemaster can end fights" }, status: :forbidden
      return
    end
    
    if @fight.ended?
      render json: { error: "Fight has already ended" }, status: :unprocessable_entity
      return
    end
    
    if @fight.end_fight!(notes: params[:notes])
      render json: ActiveModelSerializers::SerializableResource.new(
        @fight,
        serializer: FightSerializer,
        adapter: :attributes
      ).serializable_hash
    else
      render json: { error: "Failed to end fight" }, status: :unprocessable_entity
    end
  end

  def remove_image
    @fight = current_campaign.fights.find(params[:id])
    @fight.image.purge if @fight.image.attached?
    render json: @fight
  end

  private

  def require_current_campaign
    render status: 404 unless current_campaign
  end

  def set_fight
    @fight = current_campaign
      .fights
      .includes(:shots, :effects, :characters, :vehicles)
      .includes(characters: [:user, :advancements, :sites, :character_effects, :schticks, :weapons])
      .includes(vehicles: [:user])
      .find(params[:id])
  end

  def fight_params
    params.require(:fight).permit(:name, :sequence, :active, :archived, :description, :image, :started_at, :ended_at, :season, :session, character_ids: [], vehicle_ids: [])
  end

  def sort_order
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"
    if sort == "name"
      "LOWER(fights.name) #{order}, fights.id"
    elsif sort == "created_at"
      "fights.created_at #{order}, fights.id"
    elsif sort == "updated_at"
      "fights.updated_at #{order}, fights.id"
    elsif sort == "started_at"
      "fights.started_at #{order}, fights.id"
    elsif sort == "ended_at"
      "fights.ended_at #{order}, fights.id"
    elsif sort == "season"
      "fights.season #{order}, fights.session #{order}, LOWER(fights.name)"
    elsif sort == "session"
      "fights.session #{order}, LOWER(fights.name)"
    else
      "fights.created_at DESC, fights.id"
    end
  end
end
