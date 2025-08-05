class EncounterSerializer < ActiveModel::Serializer
  attributes :id, :entity_class, :name, :sequence, :description, :shots

  def entity_class
    "Encounter"
  end

  def shots
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
        [record.shot, record.characters || []]
      end
  end
end
