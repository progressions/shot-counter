class Api::V2::EncountersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def show
    @fight = Fight.find(params[:id])
    render json: @fight, serializer: EncounterSerializer
  rescue ActiveRecord::RecordNotFound
    render json: { "error" => "Encounter not found" }, status: :not_found
  end
end
