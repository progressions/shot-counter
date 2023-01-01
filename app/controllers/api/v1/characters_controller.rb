class Api::V1::CharactersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_fight
  before_action :set_character, only: [:update, :destroy]

  def index
    render json: @fight.characters
  end

  def act
    @character = @fight.characters.find(params[:id])
    if @character.act!(params[:shots] || 3)
      render json: @character
    else
      render json: @character.errors, status: 400
    end
  end

  def show
    @character = @fight.characters.find(params[:id])
    render json: @character
  end

  def create
    @character = @fight.characters.build(character_params)
    @character.user = current_user
    if @character.save
      render json: @character
    else
      render status: 400
    end
  end

  def update
    if @character.update(character_params)
      render json: @character
    else
      render @character.errors, status: 400
    end
  end

  def destroy
    @character.destroy!
    render :ok
  end

  private

  def set_character
    @character = @fight.characters.find(params[:id])
  end

  def set_fight
    @fight = Fight.find(params[:fight_id])
  end

  def character_params
    params.require(:character).permit(:name, :current_shot, :defense, :impairments, :color, :user_id, action_values: Character::DEFAULT_ACTION_VALUES.keys)
  end
end
