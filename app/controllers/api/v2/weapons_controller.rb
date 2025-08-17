class Api::V2::WeaponsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_weapon, only: [:show, :update, :destroy, :remove_image]

  def index
    per_page = (params["per_page"] || 15).to_i
    page = (params["page"] || 1).to_i
    selects = [
      "weapons.id",
      "weapons.name",
      "weapons.description",
      "weapons.created_at",
      "weapons.updated_at",
      "weapons.juncture",
      "weapons.category",
      "weapons.damage",
      "weapons.concealment",
      "weapons.reload_value",
      "weapons.mook_bonus",
      "weapons.kachunk",
    ]
    includes = [
      :image_positions,
      image_attachment: :blob,
      carries: { character: { image_attachment: :blob } },
    ]
    query = current_campaign
      .weapons
      .select(selects)
      .includes(includes)

    # Apply filters
    query = query.where(id: params["id"]) if params["id"].present?
    if params.key?("ids")
      query = params["ids"].blank? ? query.where(id: nil) : query.where(id: params["ids"].split(","))
    end
    query = query.where("weapons.name ILIKE ?", "%#{params['search']}%") if params["search"].present?
    query = query.where(params["category"] == "__NONE__" ? "weapons.category IS NULL" : "weapons.category = ?", params["category"]) if params["category"].present?
    query = query.where(params["juncture"] == "__NONE__" ? "weapons.juncture IS NULL" : "weapons.juncture = ?", params["juncture"]) if params["juncture"].present?

    # Join associations
    query = query.joins(:carries).where(carries: { character_id: params[:character_id] }) if params[:character_id].present?

    # Cache key
    cache_key = [
      "weapons/index",
      current_campaign.id,
      sort_order,
      page,
      per_page,
      params["search"],
      params["user_id"],
      params["category"],
      params["character_id"],
      params["juncture"],
      params["autocomplete"],
    ].join("/")

    cached_result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      weapons = query.order(Arel.sql(sort_order))

      categories = weapons.pluck(:category).uniq.compact.reject(&:empty?).sort
      junctures = weapons.pluck(:juncture).uniq.compact.reject(&:empty?).sort

      weapons = paginate(weapons, per_page: per_page, page: page)

      {
        "weapons" => ActiveModelSerializers::SerializableResource.new(
          weapons,
          each_serializer: params[:autocomplete] ? WeaponAutocompleteSerializer : WeaponIndexSerializer,
          adapter: :attributes
        ).serializable_hash,
        "categories" => categories,
        "junctures" => junctures,
        "meta" => pagination_meta(weapons)
      }
    end
    render json: cached_result
  end

  def batch
    ids = params[:ids].split(",")
    if ids.blank?
      render json: { weapons: [] }, status: :ok
      return
    end

    cache_key = [
      "weapons_batch",
      current_campaign.id,
      ids.sort.join(","),
      params[:per_page] || 200,
      params[:page] || 1
    ].join("/")

    cached_response = Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      weapons = current_campaign
        .weapons
        .where(id: ids)
        .select(:id, :name, :description, :image_url, :damage, :concealment, :reload_value, :mook_bonus, :kachunk, "LOWER(weapons.name) as lower_name")
      weapons = paginate(weapons, per_page: (params[:per_page] || 200), page: (params[:page] || 1))

      {
        weapons: ActiveModelSerializers::SerializableResource.new(weapons, each_serializer: EncounterWeaponSerializer).serializable_hash,
      }
    end

    render json: cached_response, status: :ok
  end

  def categories
    @categories = current_campaign.weapons.pluck(:category).uniq.compact

    if params[:search].present?
      @categories = @categories.select { |category| category.downcase.include?(params[:search].downcase) }
    end

    render json: {
      categories: @categories,
    }
  end

  def junctures
    @junctures = current_campaign.weapons.pluck(:juncture).uniq.compact

    if params[:search].present?
      @junctures = @junctures.select { |category| category.downcase.include?(params[:search].downcase) }
    end

    render json: {
      junctures: @junctures,
    }
  end

  def show
    render json: WeaponSerializer.new(@weapon).serializable_hash
  end

  def create
    # Check if request is multipart/form-data with a JSON string
    if params[:weapon].present? && params[:weapon].is_a?(String)
      begin
        weapon_data = JSON.parse(params[:weapon]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid weapon data format" }, status: :bad_request
        return
      end
    else
      weapon_data = weapon_params.to_h.symbolize_keys
    end

    weapon_data.slice(:name, :description, :active)

    @weapon = current_campaign.weapons.new(weapon_data)

    # Handle image attachment if present
    if params[:image].present?
      @weapon.image.attach(params[:image])
    end

    if @weapon.save
      render json: @weapon, status: :created
    else
      render json: { errors: @weapon.errors }, status: :unprocessable_entity
    end
  end

  def update
    @weapon = current_campaign.weapons.find(params[:id])

    # Handle multipart/form-data for updates if present
    if params[:weapon].present? && params[:weapon].is_a?(String)
      begin
        weapon_data = JSON.parse(params[:weapon]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid weapon data format" }, status: :bad_request
        return
      end
    else
      weapon_data = weapon_params.to_h.symbolize_keys
    end
    weapon_data = weapon_data.slice(:name, :description, :damage, :concealment, :reload_value, :juncture, :mook_bonus, :category, :kachunk)

    # Handle image attachment if present
    if params[:image].present?
      begin
        @weapon.image.purge if @weapon.image.attached? # Remove existing image
        @weapon.image.attach(params[:image])
      rescue StandardError => e
        Rails.logger.error("Error uploading to ImageKit")
      end
    end

    if @weapon.update(weapon_data)
      render json: @weapon.reload, serializer: WeaponSerializer, status: :ok
    else
      render json: { errors: @weapon.errors }, status: :unprocessable_entity
    end
  end

  def import
    yaml = import_params[:yaml]
    data = YAML.load(yaml)

    ImportWeapons.call(data, current_campaign)

    render :ok
  end

  def destroy
    if @weapon.carry_ids.any? && !params[:force]
      render json: { errors: { carries: true  } }, status: 400 and return
    end

    if @weapon.carry_ids.any? && params[:force]
      @weapon.carries.destroy_all
    end

    if @weapon.destroy!
      render :ok
    else
      render json: { errors: @weapon.errors }, status: 400
    end
  end

  def remove_image
    @weapon.image.purge

    if @weapon.save
      render json: @weapon.as_v1_json, status: 200
    else
      render @weapon.errors, status: 400
    end
  end

  private

  def set_weapon
    @weapon = current_campaign.weapons.find(params[:id])
  end

  def import_params
    params.require(:weapon).permit(:yaml)
  end

  def weapon_params
    params.require(:weapon).permit(:name,
     :description, :damage, :concealment, :reload_value, :juncture, :mook_bonus, :category,
     :kachunk, :image)
  end

  def pagination_meta(object)
    {
      current_page: object.current_page,
      next_page: object.next_page,
      prev_page: object.prev_page,
      total_pages: object.total_pages,
      total_count: object.total_count
    }
  end

  def sort_order
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"

    if sort == "name"
      "LOWER(weapons.name) #{order}"
    elsif sort == "created_at"
      "weapons.created_at #{order}"
    elsif sort == "updated_at"
      "weapons.updated_at #{order}"
    elsif sort == "category"
      "LOWER(weapons.category) #{order}, LOWER(weapons.name) #{order}"
    elsif sort == "juncture"
      "LOWER(weapons.juncture) #{order}, LOWER(weapons.name) #{order}"
    elsif sort == "damage"
      "weapons.damage #{order}, LOWER(weapons.name) #{order}"
    elsif sort == "concealment"
      "weapons.concealment #{order}, LOWER(weapons.name) #{order}"
    elsif sort == "reload_value"
      "weapons.reload_value #{order}, LOWER(weapons.name) #{order}"
    else
      "weapons.created_at DESC"
    end
  end
end
