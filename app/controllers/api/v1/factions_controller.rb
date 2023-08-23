class Api::V1::FactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    @factions = current_campaign
      .factions
      .order(:name)

    render json: @factions
  end

  def create
    @faction = current_campaign.factions.create!(faction_params)

    render json: @faction
  end

  private

  def faction_params
    params.require(:faction).permit(:name)
  end

end
