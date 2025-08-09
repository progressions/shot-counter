class Api::V2::PartiesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_party, only: [:show, :update, :destroy, :remove_image]

  def index
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"

    if sort == "name"
      sort = Arel.sql("LOWER(parties.name) #{order}")
    elsif sort == "created_at"
      sort = Arel.sql("parties.created_at #{order}")
    else
      sort = Arel.sql("parties.created_at DESC")
    end

    @parties = current_campaign
      .parties
      .distinct
      .with_attached_image
      .select(:id, :name, :description, :campaign_id, :faction_id, :secret, :created_at, :updated_at)
      .includes(
        { faction: [:image_attachment, :image_blob] },
        { memberships: [
          { character: [:image_attachment, :image_blob] },
          { vehicle: [:image_attachment, :image_blob] }
        ] },
        :image_positions,
      )
      .order(sort)

    ActiveRecord::Associations::Preloader.new(records: [current_campaign], associations: { user: [:image_attachment, :image_blob] })

    # @factions = current_campaign.factions.joins(:parties).where(parties: @parties).order("factions.name").distinct

    if params[:id].present?
      @parties = @parties.where(id: params[:id])
    end
    if params[:secret] == "true" && current_user.gamemaster?
      @parties = @parties.where(secret: [true, false])
    else
      @parties = @parties.where(secret: false)
    end
    if params[:search].present?
      @parties = @parties.where("name ILIKE ?", "%#{params[:search]}%")
    end
    if params[:faction_id].present?
      @parties = @parties.where(faction_id: params[:faction_id])
    end
    if params[:character_id].present?
      @parties = @parties.joins(:characters).where(characters: { id: params[:character_id] })
    end
    if params[:user_id].present?
      @parties = @parties.joins(:characters).where(characters: { user_id: params[:user_id] })
    end

    cache_key = [
      "parties/index",
      current_campaign.id,
      sort,
      order,
      params[:page],
      params[:per_page],
      params[:id],
      params[:search],
      params[:faction_id],
      params[:character_id],
      params[:user_id],
      params[:secret],
    ].join("/")

    cached_result = Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      @parties = paginate(@parties, per_page: (params[:per_page] || 6), page: (params[:page] || 1))

      {
        parties: ActiveModelSerializers::SerializableResource.new(@parties, each_serializer: PartyIndexSerializer).serializable_hash,
        # factions: ActiveModelSerializers::SerializableResource.new(@factions, each_serializer: FactionSerializer).serializable_hash,
        meta: pagination_meta(@parties),
      }
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

    party_data.slice(:name, :description, :active, :faction_id)

    @party = current_campaign.parties.new(party_data)

    # Handle image attachment if present
    if params[:image].present?
      @party.image.attach(params[:image])
    end

    if @party.save
      render json: @party, serializer: PartySerializer, status: :created
    else
      render json: { errors: @party.errors.full_messages }, status: :unprocessable_entity
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
    party_data = party_data.slice(:name, :description, :active, :faction_id, :character_ids)

    # Handle image attachment if present
    if params[:image].present?
      @party.image.purge if @party.image.attached? # Remove existing image
      @party.image.attach(params[:image])
    end

    if @party.update(party_data)
      render json: @party
    else
      render json: { errors: @party.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def fight
    @party = current_campaign.parties.find(params[:party_id])
    @fight = current_campaign.fights.find(params[:fight_id])

    @party.characters.each do |character|
      next if @fight.shots.where(character_id: character.id).exists?

      @fight.shots.create!(character: character, shot: 0)
    end

    @party.vehicles.each do |vehicle|
      next if @fight.shots.where(vehicle_id: vehicle.id).exists?

      @fight.shots.create!(vehicle: vehicle, shot: 0)
    end

    render json: @party
  end

  def destroy
    @party.destroy!

    render :ok
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

  def set_party
    @party = current_campaign.parties.find(params[:id])
  end

  def party_params
    params.require(:party).permit(:name, :description, :faction_id, :secret, :image, character_ids: [])
  end
end
