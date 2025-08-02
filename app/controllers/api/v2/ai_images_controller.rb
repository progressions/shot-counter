class Api::V2::AiImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def create
    AiImageCreationJob.perform_later(ai_params[:entity_class], ai_params[:entity_id], current_campaign.id)
    render json: { message: 'Character generation in progress' }, status: :accepted
  end

  def attach
    entity = ai_params[:entity_class].constantize.find(ai_params[:entity_id])

    updated_entity = AiService.attach_image_from_url(entity, ai_params[:image_url])

    serializer = "#{entity.class.name}Serializer".constantize

    render json: {
      entity: updated_entity, serializer: serializer,
    }
  end

  private

  def ai_params
    params.require(:ai_image).permit(:entity_class, :entity_id, :image_url)
  end
end
