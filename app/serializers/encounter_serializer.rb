class EncounterSerializer < ActiveModel::Serializer
  attributes :id, :entity_class, :name, :sequence, :description, :shots, :started_at, :ended_at, :image_url, :character_ids, :vehicle_ids

  def entity_class
    "Fight"
  end

  def shots
    # Load characters, vehicles, and associations for post-processing
    character_ids = object.shots.where.not(character_id: nil).pluck(:character_id).uniq.compact
    vehicle_ids = object.shots.where.not(vehicle_id: nil).pluck(:vehicle_id).uniq.compact
    characters_by_id = Character.where(id: character_ids).index_by(&:id)
    vehicles_by_id = Vehicle.where(id: vehicle_ids).index_by(&:id)
    carries = Carry.where(character_id: character_ids).group(:character_id).pluck(:character_id, "array_agg(weapon_id::text)")
    carries_map = carries.to_h
    schticks = CharacterSchtick.where(character_id: character_ids).group(:character_id).pluck(:character_id, "array_agg(schtick_id::text)")
    schticks_map = schticks.to_h

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
                'faction_id', characters.faction_id,
                'color', characters.color,
                'count', shots.count,
                'impairments', shots.impairments,
                'shot_id', shots.id,
                'current_shot', shots.shot
              )
            ELSE NULL
          END
          ORDER BY (
            array_position(
              ARRAY['Uber-Boss', 'Boss', 'PC', 'Featured Foe', 'Ally', 'Mook']::text[],
              COALESCE(characters.action_values->>'Type', 'Mook')
            )
          )
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
                'current_shot', shots.shot
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
          character
            .merge("image_url" => character_model&.image_url)
            .merge("faction" => character_model&.faction ? { "id" => character_model.faction.id, "name" => character_model.faction.name } : nil)
            .merge("weapon_ids" => carries_map[character_id] || [])
            .merge("schtick_ids" => schticks_map[character_id] || [])
        end
        {
          "shot" => record.shot,
          "characters" => characters,
          "vehicles" => record.vehicles || []
        }
      end
  end

  def image_url
    object.image.attached? ? object.image.url : nil
  end
end
