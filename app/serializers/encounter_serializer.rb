class EncounterSerializer < ActiveModel::Serializer
  attributes :id, :entity_class, :name, :sequence, :description, :shots, :started_at, :ended_at, :image_url

  def entity_class
    "Encounter"
  end

  def shots
    # Load characters and associations for post-processing
    character_ids = object.shots.pluck(:character_id).uniq.compact
    characters_by_id = Character.where(id: character_ids).index_by(&:id)
    carries = Carry.where(character_id: character_ids).group(:character_id).pluck(:character_id, "array_agg(weapon_id::text)")
    carries_map = carries.to_h
    schticks = CharacterSchtick.where(character_id: character_ids).group(:character_id).pluck(:character_id, "array_agg(schtick_id::text)")
    schticks_map = schticks.to_h

    object.shots
      .where(fight_id: object.id)
      .joins("LEFT JOIN characters ON characters.id = shots.character_id")
      .group("shots.shot")
      .order("shots.shot DESC NULLS LAST")
      .select(
        "shots.shot",
        "array_agg(
          jsonb_build_object(
            'id', characters.id,
            'name', characters.name,
            'entity_class', 'Character',
            'action_values', characters.action_values,
            'faction_id', characters.faction_id,
            'color', characters.color,
            'count', shots.count,
            'impairments', shots.impairments
          ) ORDER BY (
            array_position(
              ARRAY['Uber-Boss', 'Boss', 'PC', 'Featured Foe', 'Ally', 'Mook']::text[],
              COALESCE(characters.action_values->>'Type', 'Mook')
            )
          )
        ) FILTER (WHERE characters.id IS NOT NULL) AS characters"
      )
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
        [record.shot, characters]
      end
  end

  def image_url
    object.image.attached? ? object.image.url : nil
  end
end
