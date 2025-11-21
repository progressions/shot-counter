class Api::V2::AdvancementsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_character
  before_action :set_advancement, only: [:show, :update, :destroy]

  def index
    @advancements = @character.advancements.order(created_at: :desc)

    render json: @advancements, each_serializer: AdvancementSerializer
  end

  def create
    @advancement = @character.advancements.new(advancement_params)

    if @advancement.save
      ActionCable.server.broadcast(
        "campaign_#{current_campaign.id}",
        {
          type: "advancement_created",
          character_id: @character.id,
          advancement: AdvancementSerializer.new(@advancement).as_json
        }
      )
      render json: @advancement, serializer: AdvancementSerializer, status: :created
    else
      render json: { errors: @advancement.errors }, status: :unprocessable_entity
    end
  end

  def show
    render json: @advancement, serializer: AdvancementSerializer
  end

  def update
    if @advancement.update(advancement_params)
      ActionCable.server.broadcast(
        "campaign_#{current_campaign.id}",
        {
          type: "advancement_updated",
          character_id: @character.id,
          advancement: AdvancementSerializer.new(@advancement).as_json
        }
      )
      render json: @advancement, serializer: AdvancementSerializer
    else
      render json: { errors: @advancement.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    if @advancement.destroy
      ActionCable.server.broadcast(
        "campaign_#{current_campaign.id}",
        {
          type: "advancement_deleted",
          character_id: @character.id,
          advancement_id: @advancement.id
        }
      )
      head :no_content
    else
      render json: { errors: @advancement.errors }, status: :unprocessable_entity
    end
  end

  private

  def advancement_params
    params.require(:advancement).permit(:description)
  end

  def set_character
    @character = current_campaign.characters.find(params[:character_id])
  end

  def set_advancement
    @advancement = @character.advancements.find(params[:id])
  end
end
