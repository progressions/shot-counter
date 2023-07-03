class Api::V1::PartiesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_party, only: [:show, :update, :destroy]

  def index
    @parties = current_campaign.parties

    if params[:search].present?
      @parties = @parties.where("name ILIKE ?", "%#{params[:search]}%")
    end

    @parties = paginate(@parties, per_page: (params[:per_page] || 50), page: (params[:page] || 1))

    render json: {
      parties: @parties,
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
      next if @fight.fight_characters.where(character_id: character.id).exists?

      @fight.fight_characters.create!(character: character, shot: 0)
    end

    render json: @party
  end

  def destroy
    @party.destroy!

    render :ok
  end

  private

  def set_party
    @party = current_campaign.parties.find(params[:id])
  end

  def party_params
    params.require(:party).permit(:name, :description)
  end
end
