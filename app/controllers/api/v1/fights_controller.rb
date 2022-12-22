class Api::V1::FightsController < ApplicationController
  def index
    @fights = Fight.all
    render json: @fights
  end

  def show
    @fight = Fight.find(params[:id])
    render json: @fight
  end

  def update
    @fight = Fight.find(params[:id])
    if @fight.update(fight_params)
      render json: @fight
    else
      render @fight.errors, status: 400
    end
  end

  def create
    @fight = Fight.new(fight_params)
    if @fight.save
      render json: @fight
    else
      render status: 400
    end
  end

  private

  def fight_params
    params.require(:fight).permit(:name)
  end
end
