class Api::V1::FightsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_fight, only: [:show, :update, :destroy]

  def index
    Rails.logger.info("@campaign: #{campaign}")
    @fights = Fight.order(name: :asc).includes(:characters).includes(characters: :user)
    render json: @fights
  end

  def show
    render json: @fight
  end

  def create
    @fight = Fight.new(fight_params)
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

  def set_fight
    @fight = Fight.includes(:characters).includes(characters: :user).find(params[:id])
  end

  def post_to_discord(fight)
    FightPoster.post_to_discord(fight)
  end

  def fight_params
    params.require(:fight).permit(:name, :sequence)
  end
end
