class Api::V1::SchticksController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    @schticks = current_campaign.schticks.all

    render json: @schticks
  end

  def create
    @schtick = current_campaign.schticks.new(schtick_params)
    if @schtick.save
      render json: @schtick
    else
      render json: @schtick, status: 400
    end
  end

  private

  def schtick_params
    params.require(:schtick).permit(:title, :description)
  end
end
