class Api::V2::SchticksController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"

    if sort == "name"
      sort = Arel.sql("LOWER(schticks.name) #{order}")
    elsif sort == "created_at"
      sort = Arel.sql("schticks.created_at #{order}")
    else
      sort = Arel.sql("schticks.created_at DESC")
    end

    @schticks = current_campaign
      .schticks
      .includes(:prerequisite)
      .order(sort)

    @paths = []

    if params[:id].present?
      @schticks = @schticks.where(id: params[:id])
    end

    if params[:character_id].present?
      @schticks = @schticks.joins(:characters).where(characters: { id: params[:character_id] })
    end

    @categories = @schticks.pluck(:category).uniq.compact.sort

    if params[:category].present?
      @schticks = @schticks.where(category: params[:category])
      @paths = @schticks.pluck(:path).uniq.compact.sort
    end

    if params[:path].present?
      @schticks = @schticks.where(path: params[:path])
    end

    if params[:search].present?
      @schticks = @schticks.where("name ILIKE ?", "%#{params[:name]}%")
    end

    @schticks = paginate(@schticks, per_page: (params[:per_page] || 10), page: (params[:page] || 1))

    render json: {
      schticks: ActiveModelSerializers::SerializableResource.new(@schticks, each_serializer: SchtickSerializer).serializable_hash,
      meta: pagination_meta(@schticks),
      paths: @paths,
      categories: @categories
    }
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

    render json: @schtick
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

    schtick_data = schtick_data.slice(:name, :description, :active, :faction_id, :category, :path, :color)

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
    schtick_data = schtick_data.slice(:name, :description, :category, :path, :color)

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
      render json: @schtick
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
    if @schtick.destroy!
      render :ok
    else
      render json: @schtick, status: 400
    end
  end

  private

  def import_params
    params.require(:schtick).permit(:yaml)
  end

  def schtick_params
    params.require(:schtick).permit(:name, :description, :category, :path, :color, :image_url)
  end
end
