class Api::V1::LocationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_shot, only: [:index, :create]

  def create
    @location = location_params[:name]
    @shot.location = @location

    if @shot.save
      render json: @shot.location, status: :created
    else
      render json: @shot.errors, status: :unprocessable_content
    end
  end

  private

  def location_params
    params.require(:location).permit(:name)
  end

  def set_shot
    @shot = Shot.find_by(id: params[:shot_id])

    if @shot.nil?
      render json: nil, status: :ok and return
    end
  end
end
