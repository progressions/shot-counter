class Api::V1::AdvancementsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_character

  def index
    @advancements = @character.advancements.order(:created_at)

    render json: @advancements
  end

  def create
    @advancement = @character.advancements.new(advancement_params)

    if @advancement.save
      render json: @advancement
    else
      render json: @advancement, status: 422
    end
  end

  def show
    @advancement = @character.advancements.find(params[:id])

    render json: @advancement
  end

  def update
    @advancement = @character.advancements.find(params[:id])

    if @advancement.update(advancement_params)
      render json: @advancement
    else
      render json: @advancement, status: 422
    end
  end

  def destroy
    @advancement = @character.advancements.find(params[:id])

    if @advancement.destroy
      render status: 200
    else
      render json: @advancement, status: 422
    end
  end

  private

  def advancement_params
    params.require(:advancement).permit(:description)
  end

  def set_character
    @character = current_campaign.characters.find(params[:character_id])
  end
end
