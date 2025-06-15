class Api::V1::CharacterEffectsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_fight, only: [:create, :update, :destroy]

  def create
    @shot = @fight.shots.find_by(id: character_effect_params[:shot_id])
    if @shot.nil?
      render json: {
        character: ["must be present if vehicle is not set"],
        vehicle: ["must be present if character is not set"]
      }, status: 400 and return
    end
    @character_effect = @shot.character_effects.new(character_effect_params)

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

  def set_fight
    @fight = current_campaign.fights.find_by(id: params[:fight_id])
    if @fight.nil?
      render status: 404 and return
    end
  end

  def character_effect_params
    params.require(:character_effect).permit(:name, :description, :fight_id, :character_id, :vehicle_id, :severity, :action_value, :change, :shot_id)
  end
end
