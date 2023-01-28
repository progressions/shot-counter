class Api::V1::AllCharactersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_scoped_characters
  before_action :set_character, only: [:update, :destroy, :show]

  def index
    @characters = @scoped_characters.includes(:user).order(:name).all
    render json: @characters
  end

  def create
    @character = current_campaign.characters.create!(character_params)
    @character.user = current_user
    @character.campaign = current_campaign

    if @character.save
      render json: @character
    else
      render status: 400
    end
  end

  def show
    render json: @character
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
    @character = @scoped_characters.find(params[:id])
  end

  def set_scoped_characters
    if current_user.gamemaster?
      @scoped_characters = current_campaign.characters
    else
      @scoped_characters = current_user.characters
    end
  end

  def character_params
    params
      .require(:character)
      .permit(:name, :defense, :impairments, :color,
              :user_id, :active, skills: [],
              action_values: Character::DEFAULT_ACTION_VALUES.keys,
              description: Character::DEFAULT_DESCRIPTION.keys,
              schticks: [])
  end

end
