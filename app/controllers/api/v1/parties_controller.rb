class Api::V1::PartiesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    @parties = current_campaign.parties

    render json: @parties
  end

  def show
    @party = current_campaign.parties.find(params[:id])

    render json: @party
  end

  def create
    @party = current_campaign.parties.create!(party_params)

    render json: @party
  end

  def update
    @party = current_campaign.parties.find(params[:id])
    @party.update!(party_params)

    render json: @party
  end

  def destroy
    @party = current_campaign.parties.find(params[:id])
    @party.destroy!

    render :ok
  end

  private

  def party_params
    params.require(:party).permit(:name, :description)
  end
end
