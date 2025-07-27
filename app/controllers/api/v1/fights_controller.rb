class Api::V1::FightsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_fight, only: [:show, :update, :destroy, :touch]

  def index
    sort = params[:sort] || "created_at"
    order = params[:order] || "DESC"

    @fights = current_campaign
      .fights
      .where(archived: false)
      .select(:id, :campaign_id, :name, :sequence, :active, :archived, :description, :created_at, :updated_at)
      .order(sort => order)

    if params[:show_all] != "true"
      @fights = @fights.where(active: true)
    end

    @fights = paginate(@fights, per_page: (params[:per_page] || 6), page: (params[:page] || 1))

    @fights_json = @fights.map do |fight|
      character_names = fight.characters
      vehicle_names = fight.vehicles
      fight.as_v1_json.slice(:id, :name, :sequence, :active, :archived, :description, :created_at, :updated_at, :image_url).merge({
        actors: character_names + vehicle_names,
      })
    end

    render json: {
      fights: @fights_json,
      meta: pagination_meta(@fights)
    }
  end

  def show
    render json: @fight
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

    fight_data = fight_data.slice(:name, :sequence, :active, :archived, :description, :image)

    @fight = current_campaign.fights.new(fight_data)

    # Handle image attachment if present
    if params[:image].present?
      @fight.image.attach(params[:image])
    end

    if @fight.save
      render json: @fight, status: :created
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
    fight_data = fight_data.slice(:name, :sequence, :active, :archived, :description)

    # Handle image attachment if present
    if params[:image].present?
      @fight.image.purge if @fight.image.attached? # Remove existing image
      @fight.image.attach(params[:image])
    end

    if @fight.update(fight_data)
      render json: @fight
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
    params.require(:fight).permit(:name, :sequence, :active, :archived, :description, :image)
  end
end
