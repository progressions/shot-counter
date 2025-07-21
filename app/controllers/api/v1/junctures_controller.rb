class Api::V1::JuncturesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    @junctures = current_campaign.junctures.order("LOWER(junctures.name) ASC")

    Rails.logger.info("params[:active]: #{params[:active]}")

    if params[:id].present?
      @junctures = @junctures.where(id: params[:id])
    end
    if params[:hidden] == "true" && current_user.gamemaster?
      @junctures = @junctures.where(active: [true, false])
    else
      @junctures = @junctures.where(active: true)
    end
    if params[:search].present?
      @junctures = @junctures.where("name ILIKE ?", "%#{params[:search]}%")
    end
    if params[:faction_id].present?
      @junctures = @junctures.where(faction_id: params[:faction_id])
    end
    if params[:character_id].present?
      @character = current_campaign.characters.find(params[:character_id])
      @junctures = @junctures.where.not(id: @character.juncture_id)
    end

    @junctures = paginate(@junctures, per_page: (params[:per_page] || 10), page: (params[:page] || 1))

    render json: {
      junctures: @junctures,
      meta: pagination_meta(@junctures),
    }
  end

  def show
    render json: current_campaign.junctures.find(params[:id])
  end

  def create
    juncture = current_campaign.junctures.create(juncture_params)

    render json: juncture
  end

  def update
    juncture = current_campaign.junctures.find(params[:id])
    juncture.update(juncture_params)

    render json: juncture
  end

  def destroy
    juncture = current_campaign.junctures.find(params[:id])
    juncture.destroy

    render :ok
  end

  def remove_image
    @juncture = current_campaign.junctures.find(params[:id])
    @juncture.image.purge

    if @juncture.save
      render json: @juncture
    else
      render @juncture.errors, status: 400
    end
  end

  private

  def juncture_params
    params.require(:juncture).permit(:name, :description, :active, :image, :faction_id)
  end
end
