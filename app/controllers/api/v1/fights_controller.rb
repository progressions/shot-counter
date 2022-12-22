class Api::V1::FightsController < ApplicationController
  def index
    @fights = Fight.all
    render json: @fights
  end

  def create
    @fight = Fight.new(fight_params)
    if @fight.save
      render json: @fight
    end
  end

  private

  def fight_params
    params.require(:fight).permit(:name)
  end
end
