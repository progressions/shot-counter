class Api::V1::CharacterSchticksController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_character

  def index
    @schticks = @character.schticks
    @schticks = paginate(@schticks, per_page: (params[:per_page] || 10), page: (params[:page] || 1))

    render json: {
      schticks: @schticks,
      meta: pagination_meta(@schticks),
      paths: @schticks.pluck(:path).uniq.compact,
      categories: @schticks.pluck(:category).uniq.compact
    }
  end

  def create
    @schtick = current_campaign.schticks.find_by(id: schtick_params[:id])
    if @character.schticks << @schtick
      render json: @character
    else
      render json: @character, status: 400
    end
  end

  def destroy
    @schtick = current_campaign.schticks.find_by(id: params[:id])
    if @character.schticks.pluck(:prerequisite_id).include?(@schtick.id)
      render json: { error: "You cannot remove this schtick, it is a prerequisite of other schticks you know." }, status: 422 and return
    end
    if @character.schticks.delete(@schtick)
      render :ok
    else
      render json: @character.errors, status: 400
    end
  end

  private

  def schtick_params
    params.require(:schtick).permit(:id)
  end

  def set_character
    @character = current_campaign.characters.find(params[:character_id])
  end
end
