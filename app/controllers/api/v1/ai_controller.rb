class Api::V1::AiController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def create
    @json = AiCharacterService.generate_character(ai_params[:description])

    if @json.is_a?(Hash) && @json['error']
      render json: { error: @json['error'] }, status: :unprocessable_entity
    else
      render json: @json, status: :created
    end
  rescue StandardError => e
    Rails.logger.error("Error generating AI character: #{e.message}")
    render json: { error: "Failed to generate character: #{e.message}" }, status: :internal_server_error
  end

  private

  def ai_params
    params.require(:ai).permit(:description)
  end
end
