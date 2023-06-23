class Api::V1::FactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    @factions = current_campaign
      .characters
      .pluck(Arel.sql("action_values -> 'Faction'"))
      .reject { |f| f.blank? }
      .uniq
      .sort

    render json: @factions
  end

end
