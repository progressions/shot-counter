class Api::V1::PartiesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_party, only: [:show, :update, :destroy, :remove_image]

  def index
    @parties = current_campaign.parties.order("LOWER(parties.name) ASC")

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

    @factions = current_campaign.factions.joins(:parties).where(parties: @parties).order("factions.name").distinct

    @parties = paginate(@parties, per_page: (params[:per_page] || 6), page: (params[:page] || 1))

    render json: {
      parties: ActiveModelSerializers::SerializableResource.new(@parties, each_serializer: PartySerializer).serializable_hash,
      factions: ActiveModelSerializers::SerializableResource.new(current_campaign.factions.order(:name), each_serializer: FactionSerializer).serializable_hash,
      meta: pagination_meta(@parties),
    }
  end

  def show
    render json: @party
  end

  def create
    @party = current_campaign.parties.create!(party_params)

    render json: @party
  end

  def update
    @party.update!(party_params)

    render json: @party
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
    params.require(:party).permit(:name, :description, :faction_id, :secret, :image)
  end
end
