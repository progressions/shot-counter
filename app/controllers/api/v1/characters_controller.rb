class Api::V1::CharactersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_fight

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
    if @character.save
      render json: @character
    else
      render status: 400
    end
  end

  def update
    @character = @fight.characters.find(params[:id])
    if @character.update(character_params)
      render json: @character
    else
      render @character.errors, status: 400
    end
  end

  def destroy
    @fight.characters.destroy(params[:id])
    render :ok
  end

  private

  def set_fight
    @fight = Fight.find(params[:fight_id])
  end

  def character_params
    params.require(:character).permit(:name, :current_shot, :defense, :impairments, :color)
  end
end
