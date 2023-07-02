class Api::V1::CharactersAndVehiclesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_scoped_characters
  before_action :set_scoped_vehicles

  def index
    @characters = @scoped_characters
      .includes(:user)
      .includes(:carries)
      .includes(:weapons)
      .includes(:character_schticks)
      .includes(:schticks)
      .includes(:advancements)
      .includes(:sites)
      .order(:name)

    # Make this query once rather than repeating it for each action_value we're trying to pluck.
    @action_values = @characters.select(:id, :user_id, Arel.sql("action_values->'Archetype' as archetype"))
    @factions = @characters.map(&:faction).uniq.reject(&:blank?).sort
    @archetypes = @action_values.map(&:archetype).uniq.reject(&:blank?).sort

    if params[:fight_id]
      @characters = @characters.where.not(id: FightCharacter.where(fight_id: params[:fight_id]).pluck(:character_id))
    end
    if params[:show_all] != "true"
      @characters = @characters.where(active: true)
    end
    if params[:faction].present?
      @characters = @characters.where("action_values->'Faction' = ?", params[:faction].to_json)
    end
    if params[:archetype].present?
      @characters = @characters.where("action_values->'Archetype' = ?", params[:archetype].to_json)
    end
    if params[:character_type].present?
      @characters = @characters.where("action_values->'Type' = ?", params[:character_type].to_json)
    end
    if params[:search].present?
      @characters = @characters.where("name ILIKE ?", "%#{params[:search]}%")
    end

    @vehicles = @scoped_vehicles
      .includes(:user)
      .order(:name)

    if params[:fight_id]
      @vehicles = @vehicles.where.not(id: FightCharacter.where(fight_id: params[:fight_id]).pluck(:vehicle_id))
    end
    if params[:show_all] != "true"
      @characters = @characters.where(active: true)
    end
    if params[:faction].present?
      @vehicles = @vehicles.where("action_values->'Faction' = ?", params[:faction].to_json)
    end
    if params[:archetype].present?
      @vehicles = @vehicles.where("action_values->'Archetype' = ?", params[:archetype].to_json)
    end
    if params[:character_type].present?
      @vehicles = @vehicles.where("action_values->'Type' = ?", params[:character_type].to_json)
    end
    if params[:search].present?
      @vehicles = @vehicles.where("name ILIKE ?", "%#{params[:search]}%")
    end

    @characters_and_vehicles = (@characters + @vehicles).sort_by(&:name)

    @characters_and_vehicles = paginate(@characters_and_vehicles, per_page: (params[:per_page] || 50), page: (params[:page] || 1))

    render json: {
      characters: @characters_and_vehicles,
      meta: pagination_meta(@characters_and_vehicles),
      factions: @factions,
      archetypes: @archetypes
    }
  end

  private

  def set_scoped_characters
    if current_user.gamemaster?
      @scoped_characters = current_campaign.characters
    else
      @scoped_characters = current_user.characters
    end
  end

  def set_scoped_vehicles
    if current_user.gamemaster?
      @scoped_vehicles = current_campaign.vehicles
    else
      @scoped_vehicles = current_user.vehicles
    end
  end
end
