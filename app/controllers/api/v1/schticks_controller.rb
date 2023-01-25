class Api::V1::SchticksController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    @schticks = current_campaign.schticks.all

    render json: @schticks
  end

  def show
    @schtick = current_campaign.schticks.find(params[:id])

    render json: @schtick
  end

  def create
    @schtick = current_campaign.schticks.new(schtick_params)
    if @schtick.save
      render json: @schtick
    else
      render json: @schtick, status: 400
    end
  end

  def import
    yaml = import_params[:yaml]
    data = YAML.load(yaml)

    render :ok
  end

  def update
    @schtick = current_campaign.schticks.find(params[:id])
    if @schtick.update(schtick_params)
      render json: @schtick
    else
      render json: @schtick, status: 400
    end
  end

  def destroy
    @schtick = current_campaign.schticks.find(params[:id])
    if @schtick.destroy!
      render :ok
    else
      render json: @schtick, status: 400
    end
  end

  private

  def import_params
    params.require(:schtick).permit(:yaml)
  end

  def schtick_params
    params.require(:schtick).permit(:title, :description, :category, :path, :color, :image_url)
  end
end
