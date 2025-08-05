class EncounterSerializer < ActiveModel::Serializer
  attributes :id, :entity_class, :name, :sequence, :description, :shots, :started_at, :ended_at, :image_url

  def entity_class
    "Encounter"
  end

  def shots
    # Load characters to call image_url
    character_ids = object.shots.pluck(:character_id).uniq.compact
    characters_by_id = Character.where(id: character_ids).index_by(&:id)

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
        characters = (record.characters || []).map do |character|
          character_model = characters_by_id[character["id"]]
          character.merge("image_url" => character_model&.image_url)
        end
        [record.shot, characters]
      end
  end

  def image_url
    object.image.attached? ? object.image.url : nil
  end
end
