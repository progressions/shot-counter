class Api::V1::CharactersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_fight
  before_action :set_character, only: [:update, :destroy, :act]
  before_action :set_fight_character, only: [:update, :destroy, :act]

  def index
    render json: @fight.characters
  end

  def act
    if @fight_character.act!(shot_cost: params[:shots] || 3)
      render json: @character
    else
      render json: @character.errors, status: 400
    end
  end

  def add
    @character = current_campaign.characters.find(params[:id])
    @fight_character = @fight.fight_characters.build(character_id: @character.id, shot: shot_params[:current_shot])

    if @fight_character.save
      render json: @character
    else
      render status: 400
    end
  end

  def show
    @character = @fight.characters.find(params[:id])
    render json: @character
  end

  def create
    @character = current_campaign.characters.create!(character_params.merge(user: current_user))
    @fight_character = @fight.fight_characters.build(character_id: @character.id, shot: shot_params[:current_shot])

    if @fight_character.save
      render json: @character
    else
      render status: 400
    end
  end

  def update
    @fight_character.update(shot: shot_params[:current_shot]) if shot_params[:current_shot]
    if @character.update(character_params)
      render json: @character
    else
      render @character.errors, status: 400
    end
  end

  def destroy
    @fight_character.destroy!
    render :ok
  end

  private

  def set_character
    @character = @fight.characters.find(params[:id])
  end

  def set_fight_character
    @fight_character = @fight.fight_characters.find_or_create_by(character_id: @character.id)
  end

  def set_fight
    @fight = current_campaign.fights.find(params[:fight_id])
  end

  def shot_params
    params.require(:character).permit(:current_shot)
  end

  def character_params
    params.require(:character).permit(:name, :defense, :impairments, :color, :user_id, :active, action_values: Character::DEFAULT_ACTION_VALUES.keys, description: Character::DEFAULT_DESCRIPTION.keys, :schticks)
  end
end
