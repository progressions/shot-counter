class Api::V1::AiController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def create
    AiCharacterCreationJob.perform_later(ai_params[:description], current_campaign.id)
    render json: { message: 'Character generation in progress' }, status: :accepted
  end

  private

  def ai_params
    params.require(:ai).permit(:description)
  end
end
