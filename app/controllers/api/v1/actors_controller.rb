class Api::V1::ActorsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_fight
  before_action :set_character, only: [:update, :act, :reveal, :hide]
  before_action :set_shot, only: [:update, :act, :reveal, :hide]

  def index
    render json: @fight.characters.order(:name)
  end

  def act
    if @shot.act!(shot_cost: params[:shots] || 3)
      render json: @character.as_v1_json(shot: @shot)
    else
      render json: @character.errors, status: 400
    end
  end

  def add
    @character = current_campaign.characters.find(params[:id])
    @shot = @fight.shots.build(character_id: @character.id, shot: shot_params[:current_shot])
    if !@character.is_pc?
      @shot.update(count: @character.action_values["Wounds"], color: character_params[:color])
    end

    if @shot.save
      # Broadcast encounter update after adding character
      @fight.touch
      @fight.send(:broadcast_encounter_update!)
      
      render json: @character.as_v1_json(shot: @shot)
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
    if !@character.is_pc?
      @shot.update(count: @character.action_values["Wounds"], color: character_params[:color])
    end

    if @shot.save
      render json: @character.as_v1_json(shot: @shot)
    else
      render status: 400
    end
  end

  def update
    current_shot = shot_params[:current_shot] == "hidden" ? nil : shot_params[:current_shot]
    @shot.update(shot: current_shot) if shot_params[:current_shot]

    parms = character_params

    if !@character.is_pc?
      count = params[:character][:count]
      @shot.update(count: count, color: character_params[:color], impairments: character_params[:impairments])

      parms = mook_params
    end

    if @character.update(parms)
      # SyncCharacterToNotionJob.perform_later(@character.id)
      render json: @character.as_v1_json(shot: @shot)
    else
      render @character.errors, status: 400
    end
  end

  def reveal
    @shot.update(shot: 0)

    render json: @character.as_v1_json(shot: @shot)
  end

  def hide
    @shot.update(shot: nil)

    render json: @character.as_v1_json(shot: @shot)
  end

  def destroy
    @shot = Shot.find(params[:id])
    @shot.destroy!
    
    # Broadcast encounter update after removing character
    @fight.touch
    @fight.send(:broadcast_encounter_update!)
    
    render :ok
  end

  private

  def set_character
    @character = @fight.characters.find(params[:id])
  end

  def set_shot
    if params[:character][:shot_id]
      @shot = @fight.shots.find_or_create_by(id: params[:character][:shot_id], character_id: params[:id])
    else
      @shot = @fight.shots.find_by(character_id: params[:id])
    end
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
      .permit(:name, :defense, :impairments, :color, :task,
              :user_id, :active, skills: [],
              action_values: Character::DEFAULT_ACTION_VALUES.keys,
              description: Character::DEFAULT_DESCRIPTION.keys,
              schticks: [])
  end

  def mook_params
    params
      .require(:character)
      .permit(:name, :defense, :color,
              :user_id, :active, skills: [],
              action_values: Character::DEFAULT_ACTION_VALUES.keys - ["Wounds"],
              description: Character::DEFAULT_DESCRIPTION.keys,
              schticks: [])
  end

end
