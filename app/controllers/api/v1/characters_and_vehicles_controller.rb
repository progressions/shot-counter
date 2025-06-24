class Api::V1::CharactersAndVehiclesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_scoped_characters
  before_action :set_scoped_vehicles

  def index
    @characters = []
    @vehicles = []

    if params[:vehicle_id].blank?
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
      if params[:character_id].present?
        @characters = @characters.where(id: params[:character_id])
      end
      if params[:search].present?
        @characters = @characters.where("name ILIKE ?", "%#{params[:search]}%")
      end
    end

    if params[:character_id].blank?
      @vehicles = @scoped_vehicles
        .includes(:user)
        .order(:name)

      if params[:show_all] != "true"
        @vehicles = @vehicles.where(active: true)
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
      if params[:vehicle_id].present?
        @vehicles = @vehicles.where(id: params[:vehicle_id])
      end
      if params[:search].present?
        @vehicles = @vehicles.where("name ILIKE ?", "%#{params[:search]}%")
      end
    end

    @characters_and_vehicles = (@characters + @vehicles).sort_by(&:name)

    @characters_and_vehicles = paginate(@characters_and_vehicles, per_page: (params[:per_page] || 20), page: (params[:page] || 1))

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
      .shots
      .where("shot IS NOT NULL")
      .joins(:character)

    if params[:type]
      @characters = @characters.merge(Character.by_type(params[:type].split(",")))
    end

    @characters = @characters
      .order("characters.name")
      .map { |shot|
        shot
          .character
          .as_json(shot: shot)
          .slice(:id, :name, :impairments, :action_values, :location, :shot_id, :count)
      }

    render json: @characters
  end

  def vehicles
    @fight = current_campaign.fights.find(params[:id])

    @vehicles = @fight
      .shots
      .where("shot IS NOT NULL")
      .joins(:vehicle)

    if params[:type]
      @vehicles = @vehicles.merge(Vehicle.by_type(params[:type].split(",")))
    end

    @vehicles = @vehicles
      .order("vehicles.name")
      .map { |shot|
        shot
          .vehicle
          .as_json(shot: shot)
          .slice(:id, :name, :impairments, :action_values, :driver, :location, :shot_id, :count)
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
