class Api::V1::FactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_scoped_characters

  def index
    @factions = Character.pluck(Arel.sql("action_values -> 'Faction'"))

    render json: @factions
  end

  private

  def set_scoped_characters
    if current_user.gamemaster?
      @scoped_characters = current_campaign.characters
    else
      @scoped_characters = current_user.characters
    end
  end

end
