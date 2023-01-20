class Api::V1::CharacterEffectsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_fight, only: [:create, :update, :destroy]

  def create
    @character_effect = @fight.character_effects.new(character_effect_params)

    if @character_effect.save
      render json: @character_effect
    else
      render json: @character_effect.errors, status: 400
    end
  end

  private

  def require_current_campaign
    if !current_campaign
      render status: 404
    end
  end

  def set_fight
    @fight = current_campaign.fights.find_by(id: character_effect_params[:fight_id])
    if @fight.nil?
      render status: 404 and return
    end
  end

  def character_effect_params
    params.require(:character_effect).permit(:title, :description, :fight_id, :character_id)
  end
end
