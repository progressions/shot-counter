class Api::V1::FactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    @factions = current_campaign
      .factions
      .order(:name)

    render json: @factions
  end

  def show
    @faction = current_campaign.factions.find(params[:id])

    render json: @faction
  end

  def create
    @faction = current_campaign.factions.create!(faction_params)

    render json: @faction
  end

  def update
    @faction = current_campaign.factions.find(params[:id])

    @faction.update!(faction_params)

    render json: @faction
  end

  def destroy
    @faction = current_campaign.factions.find(params[:id])

    @faction.destroy!

    render :ok
  end

  private

  def faction_params
    params.require(:faction).permit(:name)
  end

end
