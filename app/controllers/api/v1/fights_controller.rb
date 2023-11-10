class Api::V1::FightsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_fight, only: [:show, :update, :destroy]

  def index
    @fights = current_campaign
      .fights
      .where(archived: false)
      .order(updated_at: :desc)

    if params[:show_all] != "true"
      @fights = @fights.where(active: true)
    end

    @fights = paginate(@fights, per_page: (params[:per_page] || 24), page: (params[:page] || 1))

    @fights_json = @fights.map do |fight|
      fight.as_json.slice(:id, :name, :sequence, :active, :archived, :description)
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
    @fight = current_campaign.fights.new(fight_params)
    if @fight.save
      render json: @fight
    else
      render status: 400
    end
  end

  def update
    if @fight.update(fight_params)
      render json: @fight
    else
      render @fight.errors, status: 400
    end
  end

  def destroy
    @fight.destroy
    render :ok
  end

  private

  def require_current_campaign
    if !current_campaign
      render status: 404
    end
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
    params.require(:fight).permit(:name, :sequence, :active, :archived, :description)
  end
end
