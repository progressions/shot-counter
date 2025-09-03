class EncounterSerializer < ActiveModel::Serializer
  attributes :id, :entity_class, :name, :sequence, :description, :shots, :started_at, :ended_at, :image_url, :character_ids, :vehicle_ids, :action_id

  def entity_class
    "Fight"
  end

  def shots
    # Load characters, vehicles, and associations for post-processing
    character_ids = object.shots.where.not(character_id: nil).pluck(:character_id).uniq.compact
    vehicle_ids = object.shots.where.not(vehicle_id: nil).pluck(:vehicle_id).uniq.compact
    shot_ids = object.shots.pluck(:id).uniq.compact
    characters_by_id = Character.where(id: character_ids).index_by(&:id)
    vehicles_by_id = Vehicle.where(id: vehicle_ids).index_by(&:id)
    carries = Carry.where(character_id: character_ids).group(:character_id).pluck(:character_id, "array_agg(weapon_id::text)")
    carries_map = carries.to_h
    schticks = CharacterSchtick.where(character_id: character_ids).group(:character_id).pluck(:character_id, "array_agg(schtick_id::text)")
    schticks_map = schticks.to_h
    
    # Load chase relationships for vehicles in this fight
    chase_relationships = ChaseRelationship.active
      .where(fight_id: object.id)
      .includes(:pursuer, :evader)
    
    # Load driver relationships - map vehicle shot_id to driver character
    # shots.driver_id indicates "this shot has a vehicle and it's being driven by driver_id"
    vehicle_shots_with_drivers = object.shots.where("driver_id IS NOT NULL").includes(:driver_shot => :character)
    drivers_by_vehicle_shot_id = vehicle_shots_with_drivers.each_with_object({}) do |shot, hash|
      if shot.driver_shot&.character
        hash[shot.id] = {
          character: shot.driver_shot.character,
          shot_id: shot.driver_shot.id
        }
      end
    end
    
    # Also map character shot_id to vehicle they're driving
    # shots.driving_id indicates "this shot has a character and they're driving driving_id"
    character_shots_driving = object.shots.where("driving_id IS NOT NULL").includes(:driving_shot => :vehicle)
    vehicles_by_driver_shot_id = character_shots_driving.each_with_object({}) do |shot, hash|
      if shot.driving_shot&.vehicle
        hash[shot.id] = {
          vehicle: shot.driving_shot.vehicle,
          shot_id: shot.driving_shot.id,
          vehicle_model: shot.driving_shot.vehicle  # Keep the actual model for image_url
        }
      end
    end
    
    # Load character effects grouped by shot_id
    character_effects = CharacterEffect.where(shot_id: shot_ids)
      .select(:id, :name, :description, :severity, :action_value, :change, :shot_id, :character_id, :vehicle_id)
    effects_by_shot_id = character_effects.group_by(&:shot_id)

    object.shots
      .where(fight_id: object.id)
      .group("shots.shot")
      .order("shots.shot DESC NULLS LAST")
      .select(
        "shots.shot",
        "array_agg(
          CASE
            WHEN shots.character_id IS NOT NULL THEN
              jsonb_build_object(
                'id', characters.id,
                'name', characters.name,
                'entity_class', 'Character',
                'action_values', characters.action_values,
                'skills', characters.skills,
                'faction_id', characters.faction_id,
                'color', characters.color,
                'count', shots.count,
                'impairments', CASE 
                  WHEN characters.action_values->>'Type' = 'PC' THEN characters.impairments
                  ELSE shots.impairments
                END,
                'shot_id', shots.id,
                'current_shot', shots.shot,
                'location', shots.location,
                'driving_id', shots.driving_id
              )
            ELSE NULL
          END
          ORDER BY 
            array_position(
              ARRAY['Uber-Boss', 'Boss', 'PC', 'Ally', 'Featured Foe', 'Mook']::text[],
              COALESCE(characters.action_values->>'Type', 'Mook')
            ),
            (COALESCE((characters.action_values->>'Speed')::int, 0) - COALESCE(
              CASE 
                WHEN characters.action_values->>'Type' = 'PC' THEN characters.impairments
                ELSE shots.impairments
              END, 0)) DESC,
            LOWER(characters.name) ASC
        ) FILTER (WHERE shots.character_id IS NOT NULL) AS characters",
        "array_agg(
          CASE
            WHEN shots.vehicle_id IS NOT NULL THEN
              jsonb_build_object(
                'id', vehicles.id,
                'name', vehicles.name,
                'entity_class', 'Vehicle',
                'action_values', vehicles.action_values,
                'shot_id', shots.id,
                'current_shot', shots.shot,
                'location', shots.location,
                'driver_id', shots.driver_id
              )
            ELSE NULL
          END
        ) FILTER (WHERE shots.vehicle_id IS NOT NULL) AS vehicles"
      )
      .joins("LEFT JOIN characters ON characters.id = shots.character_id")
      .joins("LEFT JOIN vehicles ON vehicles.id = shots.vehicle_id")
      .map do |record|
        characters = (record.characters || []).map do |character|
          character_id = character["id"]
          character_model = characters_by_id[character_id]
          shot_id = character["shot_id"]
          # Get vehicle this character is driving
          driving_info = vehicles_by_driver_shot_id[shot_id]
          # Get effects for this specific shot/character
          char_effects = effects_by_shot_id[shot_id]&.select { |e| e.character_id == character_id } || []
          character
            .merge("image_url" => character_model&.image_url)
            .merge("faction" => character_model&.faction ? { "id" => character_model.faction.id, "name" => character_model.faction.name } : nil)
            .merge("weapon_ids" => carries_map[character_id] || [])
            .merge("schtick_ids" => schticks_map[character_id] || [])
            .merge("effects" => char_effects.map { |e| 
              {
                "id" => e.id,
                "name" => e.name,
                "description" => e.description,
                "severity" => e.severity,
                "action_value" => e.action_value,
                "change" => e.change,
                "shot_id" => e.shot_id,
                "character_id" => e.character_id
              }
            })
            .merge(
              "driving" => driving_info ? {
                "id" => driving_info[:vehicle_model].id,
                "name" => driving_info[:vehicle_model].name,
                "entity_class" => "Vehicle",
                "shot_id" => driving_info[:shot_id],
                "action_values" => driving_info[:vehicle_model].action_values,
                "image_url" => driving_info[:vehicle_model].image_url,  # This will call the model method
                "color" => driving_info[:vehicle_model].color,
                "impairments" => driving_info[:vehicle_model].impairments || 0,
                "faction_id" => driving_info[:vehicle_model].faction_id,
                "faction" => driving_info[:vehicle_model].faction ? { 
                  "id" => driving_info[:vehicle_model].faction.id, 
                  "name" => driving_info[:vehicle_model].faction.name 
                } : nil
              } : nil
            )
        end
        vehicles = (record.vehicles || []).map do |vehicle|
          vehicle_id = vehicle["id"]
          shot_id = vehicle["shot_id"]
          vehicle_model = vehicles_by_id[vehicle_id]
          # Get driver for this vehicle
          driver_info = drivers_by_vehicle_shot_id[shot_id]
          # Get effects for this specific shot/vehicle
          vehicle_effects = effects_by_shot_id[shot_id]&.select { |e| e.vehicle_id == vehicle_id } || []
          
          # Get chase relationships for this vehicle
          vehicle_chase_relationships = chase_relationships.select { |cr| 
            cr.pursuer_id == vehicle_id || cr.evader_id == vehicle_id 
          }.map { |cr|
            {
              "id" => cr.id,
              "position" => cr.position,
              "pursuer_id" => cr.pursuer_id,
              "evader_id" => cr.evader_id,
              "is_pursuer" => cr.pursuer_id == vehicle_id
            }
          }
          
          vehicle
            .merge("image_url" => vehicle_model&.image_url)
            .merge("chase_relationships" => vehicle_chase_relationships)
            .merge("effects" => vehicle_effects.map { |e|
            {
              "id" => e.id,
              "name" => e.name,
              "description" => e.description,
              "severity" => e.severity,
              "action_value" => e.action_value,
              "change" => e.change,
              "shot_id" => e.shot_id,
              "vehicle_id" => e.vehicle_id,
              "driver_id" => e.driver_id,
            }
          }).merge(
            "driver" => driver_info ? {
              "id" => driver_info[:character].id,
              "name" => driver_info[:character].name,
              "entity_class" => "Character",
              "shot_id" => driver_info[:shot_id]
            } : nil
          )
        end
        {
          "shot" => record.shot,
          "characters" => characters,
          "vehicles" => vehicles
        }
      end
  end
end
