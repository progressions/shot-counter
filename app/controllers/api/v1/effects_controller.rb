class Api::V1::EffectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_fight
  before_action :set_effect, only: [:update, :destroy, :act]
  before_action :set_fight_effect, only: [:update, :destroy, :act]

  def index
    render json: @fight.effects
  end

  def show
    @effect = @fight.effects.find(params[:id])
    render json: @effect
  end

  def create
    if @effect = @fight.effects.create!(effect_params.merge(user: current_user))
      render json: @effect
    else
      render status: 400
    end
  end

  def update
    if @effect.update(effect_params)
      render json: @effect
    else
      render @effect.errors, status: 400
    end
  end

  def destroy
    @fight_effect.destroy!
    render :ok
  end

  private

  def set_effect
    @effect = @fight.effects.find(params[:id])
  end

  def set_fight
    @fight = Fight.find(params[:fight_id])
  end

  def effect_params
    params.require(:effect).permit(:title, :description, :severity, :start_sequence, :end_sequence, :start_shot, :end_shot, :severity)
  end
end
