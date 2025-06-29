class Api::V1::SuggestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    @characters = current_campaign.characters.order(:name).where("name ILIKE ?", "%#{params[:query]}%").limit(10)

    @characters_json = @characters.map do |character|
      {
        className: "Character",
        id: character.id,
        label: character.name,
      }
    end

    render json: @characters_json
  end

end
