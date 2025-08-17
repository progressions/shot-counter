class Api::V2::SchticksController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    Rails.logger.info("SCHTICKS PARAMS #{params.inspect}")
    per_page = (params["per_page"] || 15).to_i
    page = (params["page"] || 1).to_i
    selects = [
      "schticks.id",
      "schticks.name",
      "schticks.description",
      "schticks.created_at",
      "schticks.updated_at",
      "schticks.category",
      "schticks.path",
      "schticks.prerequisite_id",
    ]
    includes = [
      :image_positions,
      image_attachment: :blob,
      character_schticks: { character: { image_attachment: :blob } },
    ]
    query = current_campaign
      .schticks
      .select(selects)
      .includes(includes)

    # Apply filters
    query = query.where(id: params["id"]) if params["id"].present?
    if params.key?("ids")
      query = params["ids"].blank? ? query.where(id: nil) : query.where(id: params["ids"].split(","))
    end
    query = query.where("schticks.name ILIKE ?", "%#{params['search']}%") if params["search"].present?
    query = query.where(params["category"] == "__NONE__" ? "schticks.category IS NULL" : "schticks.category = ?", params["category"]) if params["category"].present?
    query = query.where(params["path"] == "__NONE__" ? "schticks.path IS NULL" : "schticks.path = ?", params["path"]) if params["path"].present?

    # Join associations
    query = query.joins(:character_schticks).where(character_schticks: { character_id: params[:character_id] }) if params[:character_id].present?

    # Cache key
    cache_key = [
      "schticks/index",
      current_campaign.id,
      sort_order,
      page,
      per_page,
      params["search"],
      params["user_id"],
      params["category"],
      params["character_id"],
      params["autocomplete"],
      params["path"],
    ].join("/")

    cached_result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      schticks = query.order(Arel.sql(sort_order))

      # Get categories without applying full sort_order
      categories_query = query.select("schticks.category").distinct
      categories = categories_query.pluck(:category).uniq

      # Get seasons without applying full sort_order
      paths_query = query.select("schticks.path").distinct
      paths = paths_query.pluck(:path).uniq

      schticks = paginate(schticks, per_page: per_page, page: page)

      {
        "schticks" => ActiveModelSerializers::SerializableResource.new(
          schticks,
          each_serializer: params[:autocomplete] ? SchtickAutocompleteSerializer : SchtickIndexLiteSerializer,
          adapter: :attributes
        ).serializable_hash,
        "categories" => categories,
        "paths" => paths,
        "meta" => pagination_meta(schticks)
      }
    end
    render json: cached_result
  end

  def batch
    unless params.key?("ids")
      render json: { error: "ids parameter is required" }, status: :bad_request
      return
    end
    if params["ids"].blank?
      render json: { schticks: [], categories: [], meta: { current_page: 1, next_page: nil, prev_page: nil, total_pages: 1, total_count: 0 } }, status: :ok
      return
    end
    ids = params["ids"].split(",")
    cache_key = [
      "schticks_batch",
      current_campaign.id,
      ids.sort.join(","),
      params["per_page"] || 200,
      params["page"] || 1
    ].join("/")
    cached_response = Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      schticks = current_campaign
        .schticks
        .where(id: ids)
        .select(:id, :name, :description, :image_url, :category, :path)
      schticks = paginate(schticks, per_page: (params[:per_page] || 200), page: (params[:page] || 1))
      {
        schticks: ActiveModelSerializers::SerializableResource.new(schticks, each_serializer: EncounterSchtickSerializer).serializable_hash,
        categories: [],
        meta: pagination_meta(schticks)
      }
    end
    render json: cached_response, status: :ok
  end

  def categories
    all_categories = current_campaign.schticks.pluck(:category).uniq.compact
    core_categories = current_campaign.schticks.where(path: "Core").pluck(:category).uniq.compact
    general_categories = all_categories - core_categories

    if params[:search].present?
      search = params[:search].downcase
      general_categories = general_categories.select { |category| category.downcase.include?(search) }
      core_categories = core_categories.select { |category| category.downcase.include?(search) }
    end

    render json: {
      general: general_categories.sort,
      core: core_categories.sort
    }
  end

  def paths
    @paths = current_campaign.schticks

    if params[:category].present?
      @paths = @paths.where(category: params[:category])
    end
    if params[:search].present?
      @paths = @paths.where("path ILIKE ?", "%#{params[:search]}%")
    end

    @paths = @paths.pluck(:path).uniq.compact.reject(&:empty?).sort_by!(&:downcase)

    render json: {
      paths: @paths,
    }
  end

  def show
    @schtick = current_campaign.schticks.find(params[:id])

    render json: @schtick, serializer: SchtickSerializer
  end

  def create
    # Check if request is multipart/form-data with a JSON string
    if params[:schtick].present? && params[:schtick].is_a?(String)
      begin
        schtick_data = JSON.parse(params[:schtick]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid schtick data format" }, status: :bad_request
        return
      end
    else
      schtick_data = schtick_params.to_h.symbolize_keys
    end

    schtick_data = schtick_data.slice(:name, :description, :active, :category, :path, :color, :prerequisite_id)

    @schtick = current_campaign.schticks.new(schtick_data)

    # Handle image attachment if present
    if params[:image].present?
      @schtick.image.attach(params[:image])
    end

    if @schtick.save
      render json: @schtick, status: :created
    else
      render json: { errors: @schtick.errors }, status: :unprocessable_entity
    end
  end

  def update
    @schtick = current_campaign.schticks.find(params[:id])

    # Handle multipart/form-data for updates if present
    if params[:schtick].present? && params[:schtick].is_a?(String)
      begin
        schtick_data = JSON.parse(params[:schtick]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid schtick data format" }, status: :bad_request
        return
      end
    else
      schtick_data = schtick_params.to_h.symbolize_keys
    end
    schtick_data = schtick_data.slice(:name, :description, :category, :path, :color, :prerequisite_id)

    # Handle image attachment if present
    if params[:image].present?
      begin
        @schtick.image.purge if @schtick.image.attached? # Remove existing image
        @schtick.image.attach(params[:image])
      rescue StandardError => e
        Rails.logger.error("Error uploading to ImageKit")
      end
    end

    if @schtick.update(schtick_data)
      render json: @schtick.reload
    else
      render json: { errors: @schtick.errors}, status: :unprocessable_entity
    end
  end

  def import
    yaml = import_params[:yaml]
    data = YAML.load(yaml)

    ImportSchticks.call(data, current_campaign)

    render :ok
  end

  def destroy
    @schtick = current_campaign.schticks.find(params[:id])

    if @schtick.character_schtick_ids.any? && !params[:force]
      render json: { errors: { characters: true  } }, status: 400 and return
    end

    if @schtick.character_schtick_ids.any? && params[:force]
      @schtick.character_schticks.destroy_all
    end

    if @schtick.destroy!
      render :ok
    else
      render json: { errors: @schtick.errors }, status: 400
    end
  end

  private

  def import_params
    params.require(:schtick).permit(:yaml)
  end

  def schtick_params
    params.require(:schtick).permit(:name, :description, :category, :path, :color, :image_url, :prerequisite_id)
  end

  def sort_order
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"
    if sort == "name"
      "LOWER(schticks.name) #{order}, schticks.id"
    elsif sort == "category"
      "LOWER(schticks.category) #{order}, LOWER(schticks.name) #{order}, schticks.id"
    elsif sort == "path"
      "LOWER(schticks.path) #{order}, LOWER(schticks.name) #{order}, schticks.id"
    elsif sort == "created_at"
      "schticks.created_at #{order}, schticks.id"
    elsif sort == "updated_at"
      "schticks.updated_at #{order}, schticks.id"
    else
      "schticks.created_at DESC, schticks.id"
    end
  end
end
