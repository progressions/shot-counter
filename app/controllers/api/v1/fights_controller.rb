class Api::V1::FightsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_fight, only: [:show, :update, :destroy]

  def index
    Rails.logger.info("@campaign: #{current_campaign}")
    @fights = current_campaign.fights.order(name: :asc).includes(:characters).includes(characters: :user)
    render json: @fights
  end

  def show
    render json: @fight
  end

  def create
    @fight = current_campaign.fights.new(fight_params)
    if @fight.save
      post_to_discord(@fight)
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
    @fight = current_campaign.fights.includes(:characters).includes(characters: :user).find(params[:id])
  end

  def post_to_discord(fight)
    # FightPoster.post_to_discord(fight)
  end

  def fight_params
    params.require(:fight).permit(:name, :sequence, :active)
  end
end
