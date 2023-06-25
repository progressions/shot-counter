class Api::V1::CharacterEffectsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_fight, only: [:create, :update, :destroy]

  def create
    @fight_character = @fight.fight_characters.find_by(character_id: character_effect_params[:character_id])
    if @fight_character.nil?
      render json: {
        character: ["must be present if vehicle is not set"],
        vehicle: ["must be present if character is not set"]
      }, status: 400 and return
    end
    @character_effect = @fight_character.character_effects.new(character_effect_params)

    if @character_effect.save
      render json: @character_effect
    else
      render json: @character_effect.errors, status: 400
    end
  end

  def update
    @character_effect = @fight.character_effects.find_by(id: params[:id])

    if !@character_effect
      render status: 404 and return
    end

    if @character_effect.update(character_effect_params)
      render json: @character_effect
    else
      render json: @character_effect.errors, status: 400
    end
  end

  def destroy
    @character_effect = @fight.character_effects.find_by(id: params[:id])

    if @character_effect.destroy!
      render :ok
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
    @fight = current_campaign.fights.find_by(id: params[:fight_id])
    if @fight.nil?
      render status: 404 and return
    end
  end

  def character_effect_params
    params.require(:character_effect).permit(:title, :description, :fight_id, :character_id, :vehicle_id, :severity, :action_value, :change).merge(fight_id: @fight.id)
  end
end
