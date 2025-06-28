class Api::V1::SuggestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    @weapons = current_campaign.weapons.order(:name).where("name ILIKE ?", "%#{params[:query]}%")

    Rails.logger.info("WEAPONS SUGGESTIONS: #{params[:query]} - #{@weapons.count} results")

    @weapons_json = @weapons.map do |weapon|
      {
        class: "Weapon",
        id: weapon.id,
        label: weapon.name,
      }
    end

    render json: @weapons_json
  end

end
