class Api::V2::WeaponsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_weapon, only: [:show, :update, :destroy, :remove_image]

  def index
    @weapons = current_campaign
      .weapons
      .order(:juncture, :name)

    @categories = []

    @junctures = @weapons.pluck(:juncture).uniq.compact

    if params[:id].present?
      @weapons = @weapons.where(id: params[:id])
    end

    if params[:juncture].present?
      @weapons = @weapons.where(juncture: params[:juncture])
    end

    @categories = @weapons.where("category != ?", "").pluck(:category).uniq.compact

    if params[:category].present?
      @weapons = @weapons.where(category: params[:category])
    end

    if params[:name].present?
      @weapons = @weapons.where("name ILIKE ?", "%#{params[:name]}%")
    end

    @weapons = paginate(@weapons, per_page: (params[:per_page] || 10), page: (params[:page] || 1))

    render json: {
      weapons: @weapons,
      meta: pagination_meta(@weapons),
      junctures: @junctures,
      categories: @categories
    }
  end

  def show
    render json: @weapon.as_v1_json
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

    weapon_data.slice(:name, :description, :active, :faction_id)

    @weapon = current_campaign.weapons.new(weapon_data)

    # Handle image attachment if present
    if params[:image].present?
      @weapon.image.attach(params[:image])
    end

    if @weapon.save
      render json: @weapon, status: :created
    else
      render json: { errors: @weapon.errors.full_messages }, status: :unprocessable_entity
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
      render json: @weapon
    else
      render json: { errors: @weapon.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def import
    yaml = import_params[:yaml]
    data = YAML.load(yaml)

    ImportWeapons.call(data, current_campaign)

    render :ok
  end

  def destroy
    if @weapon.destroy!
      render :ok
    else
      render json: @weapon.as_v1_json, status: 400
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
end
