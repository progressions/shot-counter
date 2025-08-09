class Api::V2::FightsController < ApplicationController
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
      "fights.created_at",
      "fights.updated_at",
      "fights.started_at",
      "fights.ended_at",
      "fights.active",
    ]
    includes = [
      :image_positions,
      image_attachment: :blob,
      shots: { character: { image_attachment: :blob } },
      shots: { vehicle: { image_attachment: :blob } },
    ]
    query = current_campaign
      .fights
      .select(selects)
      .includes(includes)

    # Apply filters
    query = query.where("fights.name ILIKE ?", "%#{params['search']}%") if params["search"].present?
    if params["show_all"] == "true"
      query = query.where(active: [true, false, nil])
    else
      query = query.where(active: true)
    end
    query = query.where(id: params["id"]) if params["id"].present?
    query = query.where(started_at: nil) if params["unstarted"].present?
    query = query.where.not(started_at: nil).where(ended_at: nil) if params["unended"].present?
    # Join associations
    query = query.joins(:shots).where(shots: { character_id: params[:character_id] }) if params[:character_id].present?
    query = query.joins(:shots).where(shots: { vehicle_id: params[:vehicle_id] }) if params[:vehicle_id].present?

    # Cache key
    cache_key = [
      "fights/index",
      current_campaign.id,
      sort_order,
      page,
      per_page,
      params["search"],
      params["active"],
      params["character_id"],
      params["vehicle_id"],
      params["autocomplete"],
    ].join("/")

    ActiveRecord::Associations::Preloader.new(records: [current_campaign], associations: { user: [:image_attachment, :image_blob] })

    cached_result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      fights = query.order(Arel.sql(sort_order))
      fights = paginate(fights, per_page: per_page, page: page)
      {
        "fights" => ActiveModelSerializers::SerializableResource.new(
          fights,
          each_serializer: params[:autocomplete] ? FightAutocompleteSerializer : FightIndexLiteSerializer,
        ).serializable_hash,
        "meta" => pagination_meta(fights)
      }
    end
    render json: cached_result
  end

  def indexz
    @fights = current_campaign
      .fights
      .distinct
      .with_attached_image
      .where(archived: false)
      .select(:id, :campaign_id, :name, :sequence, :active, :archived, :description, :created_at,
              :updated_at, :started_at, :ended_at, :season, :session, "LOWER(fights.name) AS lower_name")
      .includes(
        { characters: [:image_attachment, :image_blob] },
        { vehicles: [:image_attachment, :image_blob] },
        :image_positions,
        { shots: [{ character: [:image_attachment, :image_blob] }, { vehicle: [:image_attachment, :image_blob] }] }
      )
      .order(Arel.sql(sort_order))

    ActiveRecord::Associations::Preloader.new(records: [current_campaign], associations: { user: [:image_attachment, :image_blob] })

    if params[:show_all] != "true"
      @fights = @fights.where(active: true)
    end
    if params[:unstarted].present?
      @fights = @fights.where(started_at: nil)
    end
    if params[:unended].present?
      @fights = @fights.where(ended_at: nil)
    end
    if params[:user_id].present?
      @fights = @fights.joins(:characters).where(characters: { user_id: params[:user_id] })
    end
    if params[:id].present?
      @fights = @fights.where(id: params[:id])
    end
    if params[:search].present?
      @fights = @fights.where("name ILIKE ?", "%#{params[:search]}%")
    end
    if params[:character_id].present?
      @fights = @fights.joins(:shots).where(shots: { character_id: params[:character_id] })
    end

    cache_key = [
      "fights/index",
      current_campaign.id,
      sort_order,
      params[:page],
      params[:per_page],
      params[:show_all],
      params[:unstarted],
      params[:unended],
      params[:id],
      params[:search],
      params[:character_id],
      params[:user_id],
    ].join("/")

    cached_result = Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      @fights = paginate(@fights, per_page: (params[:per_page] || 6), page: (params[:page] || 1))
      {
        fights: ActiveModelSerializers::SerializableResource.new(@fights, each_serializer: FightSerializer).serializable_hash,
        meta: pagination_meta(@fights)
      }
    end

    render json: cached_result
  end

  def show
    render json: @fight, serializer: FightSerializer, status: :ok
  end

  def create
    # Check if request is multipart/form-data with a JSON string
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

    # Handle image attachment if present
    if params[:image].present?
      @fight.image.attach(params[:image])
      extension = params[:image].original_filename.split('.').last
      @fight.image.blob.update(imagekit_filename: "image_#{@fight.id}__#{rand(1000)}__#{SecureRandom.hex(4)}.#{extension}")
    end

    if @fight.save
      render json: @fight, serializer: FightSerializer, status: :created
    else
      render json: { errors: @fight.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @fight = current_campaign.fights.find(params[:id])

    # Handle multipart/form-data for updates if present
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

    # Handle image attachment if present
    if params[:image].present?
      @fight.image.purge if @fight.image.attached? # Remove existing image
      @fight.image.attach(params[:image])
      extension = params[:image].original_filename.split('.').last
      @fight.image.blob.update(imagekit_filename: "image_#{@fight.id}__#{rand(1000)}__#{SecureRandom.hex(4)}.#{extension}")
      binding.pry
    end

    if @fight.update(fight_data)
      render json: @fight.reload, serializer: FightSerializer, status: :ok
    else
      render json: { errors: @fight.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def touch
    @fight.send(:broadcast_update)

    render json: @fight
  end

  def destroy
    @fight.destroy
    render :ok
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
    else
      "fights.created_at DESC, fights.id"
    end
  end
end
