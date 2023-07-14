class Api::V1::ActorsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_fight
  before_action :set_character, only: [:update, :destroy, :act, :reveal, :hide]
  before_action :set_shot, only: [:update, :destroy, :act, :reveal, :hide]

  def index
    render json: @fight.characters.order(:name)
  end

  def act
    if @shot.act!(shot_cost: params[:shots] || 3)
      render json: @character
    else
      render json: @character.errors, status: 400
    end
  end

  def add
    @character = current_campaign.characters.find(params[:id])
    @shot = @fight.shots.build(character_id: @character.id, shot: shot_params[:current_shot])
    if @character.action_values["Type"] == "Mook"
      @shot.mook = Mook.new(count: @character.action_values["Wounds"], color: character_params[:color])
    end

    if @shot.save
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
    @shot = @fight.shots.build(character_id: @character.id, shot: shot_params[:current_shot])
    if @character.action_values["Type"] == "Mook"
      @shot.mook = Mook.new(count: @character.action_values["Wounds"], color: character_params[:color])
    end

    if @shot.save
      render json: @character
    else
      render status: 400
    end
  end

  def update
    current_shot = shot_params[:current_shot] == "hidden" ? nil : shot_params[:current_shot]
    @shot.update(shot: current_shot) if shot_params[:current_shot]

    parms = character_params

    if @character.action_values["Type"] == "Mook"
      count = params[:character][:count]
      @shot.mook ||= Mook.new(count: @character.action_values["Wounds"], color: character_params[:color])
      @shot.mook.update(count: count, color: character_params[:color])
      parms = mook_params
    end

    if @character.update(parms)
      render json: @character
    else
      render @character.errors, status: 400
    end
  end

  def reveal
    @shot.update(shot: 0)

    render json: @character
  end

  def hide
    @shot.update(shot: nil)

    render json: @character
  end

  def destroy
    @shot.destroy!
    render :ok
  end

  private

  def set_character
    @character = @fight.characters.find(params[:id])
  end

  def set_shot
    @shot = @fight.shots.find_or_create_by(character_id: @character.id)
  end

  def set_fight
    @fight = current_campaign.fights.find(params[:fight_id])
  end

  def shot_params
    params.require(:character).permit(:current_shot)
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

  def mook_params
    params
      .require(:character)
      .permit(:name, :defense, :impairments, :color,
              :user_id, :active, skills: [],
              action_values: Character::DEFAULT_ACTION_VALUES.keys - ["Wounds"],
              description: Character::DEFAULT_DESCRIPTION.keys,
              schticks: [])
  end

end
