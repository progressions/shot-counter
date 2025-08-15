class Api::V2::AiController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def create
    AiCharacterCreationJob.perform_later(ai_params[:description], current_campaign.id)
    render json: { message: 'Character generation in progress' }, status: :accepted
  end

  def extend
    @character = current_campaign.characters.find(params[:id])
    AiCharacterUpdateJob.perform_later(@character.id)
  end

  private

  def ai_params
    params.require(:ai).permit(:description)
  end
end
