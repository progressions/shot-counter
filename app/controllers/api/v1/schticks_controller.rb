class Api::V1::SchticksController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    @schticks = current_campaign
      .schticks
      .includes(:prerequisite)
      .order(:category, :path, :name)

    @paths = []

    if params[:id].present?
      @schticks = @schticks.where(id: params[:id])
    end

    if params[:character_id].present?
      @character = current_campaign.characters.find(params[:character_id])
      if @character.action_values["Type"] == "PC"
        @schticks = @schticks
          .where(prerequisite_id: [@character.schtick_ids, nil].flatten)
          .where.not(id: @character.schtick_ids)
      else
        @schticks = @schticks
          .where.not(id: @character.schtick_ids)
      end
    end

    @categories = @schticks.pluck(:category).uniq.compact

    if params[:category].present?
      @schticks = @schticks.where(category: params[:category])
      @paths = @schticks.pluck(:path).uniq.compact
    end

    if params[:path].present?
      @schticks = @schticks.where(path: params[:path])
    end

    if params[:name].present?
      @schticks = @schticks.where("name ILIKE ?", "%#{params[:name]}%")
    end

    @schticks = paginate(@schticks, per_page: (params[:per_page] || 10), page: (params[:page] || 1))

    render json: {
      schticks: @schticks,
      meta: pagination_meta(@schticks),
      paths: @paths,
      categories: @categories
    }
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

    ImportSchticks.call(data, current_campaign)

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
    params.require(:schtick).permit(:name, :description, :category, :path, :color, :image_url)
  end
end
