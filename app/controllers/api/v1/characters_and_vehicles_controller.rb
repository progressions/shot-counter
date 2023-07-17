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
    @archetypes = @action_values.map(&:archetype).uniq.reject(&:blank?).sort

    @factions = current_campaign.factions.joins(:characters).where(characters: @characters).order("factions.name").distinct

    if params[:fight_id]
      # @characters = @characters.where.not(id: Shot.where(fight_id: params[:fight_id]).pluck(:character_id))
    end
    if params[:show_all] != "true"
      @characters = @characters.where(active: true)
    end
    if params[:faction].present?
      @characters = @characters.joins(:faction).where("factions.name ILIKE ?", "%#{params[:faction]}%")
    end
    if params[:faction_id].present?
      @characters = @characters.where(faction_id: params[:faction_id])
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
      # @vehicles = @vehicles.where.not(id: Shot.where(fight_id: params[:fight_id]).pluck(:vehicle_id))
    end
    if params[:show_all] != "true"
      @characters = @characters.where(active: true)
    end
    if params[:faction].present?
      @vehicles = @vehicles.joins(:faction).where("factions.name ILIKE ?", "%#{params[:faction]}%")
    end
    if params[:faction_id].present?
      @vehicles = @vehicles.where(faction_id: params[:faction_id])
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

  def characters
    @fight = current_campaign.fights.find(params[:id])
    @characters = @fight
      .characters
      .by_type(["PC", "Ally"])
      .order(:name)
      .map { |c|
        c.as_json.slice(:id, :name, :impairments, :action_values)
      }

    render json: @characters
  end

  def vehicles
    @fight = current_campaign.fights.find(params[:id])

    @vehicles = @fight
      .shots
      .joins(:vehicle)
      .merge(Vehicle.by_type(["PC", "Ally"]))
      .order("vehicles.name")
      .map { |shot|
        shot
          .vehicle
          .as_json(shot: shot)
          .slice(:id, :name, :impairments, :action_values, :driver)
      }

    render json: @vehicles
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
