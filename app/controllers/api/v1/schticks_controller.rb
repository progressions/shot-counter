class Api::V1::SchticksController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    @schticks = current_campaign
      .schticks
      .includes(:prerequisite)
      .order(:category, :path, :title)

    @paths = []

    if params[:character_id].present?
      @character = current_campaign.characters.find(params[:character_id])
      if @character.action_values["Type"] == "PC"
        @schticks = @schticks
          .for_archetype(@character.action_values["Archetype"])
          .where(prerequisite_id: [@character.schtick_ids, nil].flatten)
      else
        @schticks = @schticks.where(category: "Foe")
      end
    end

    if params[:category].present?
      @schticks = @schticks.where(category: params[:category])
      @paths = @schticks.pluck(:path).uniq.compact
    end

    if params[:path].present?
      @schticks = @schticks.where(path: params[:path])
    end

    if params[:title].present?
      @schticks = @schticks.where("title LIKE ?", "%#{params[:title]}%")
    end

    @schticks = @schticks.page(params[:page] ? params[:page].to_i : 1)

    render json: {
      schticks: @schticks,
      meta: pagination_meta(@schticks),
      paths: @paths
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
    params.require(:schtick).permit(:title, :description, :category, :path, :color, :image_url)
  end

  def pagination_meta(object)
    {
      current_page: object.current_page,
      next_page: object.next_page,
      prev_page: object.prev_page,
      total_pages: object.total_pages,
      total_count: object.total_count
    }
  end
end
