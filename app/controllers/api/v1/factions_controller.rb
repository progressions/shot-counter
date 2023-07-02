class Api::V1::FactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    @factions = current_campaign
      .factions
      .order(:name)

    render json: @factions.map(&:name)
  end

end
