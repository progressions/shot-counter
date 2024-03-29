class Fight < ApplicationRecord
  belongs_to :campaign
  has_many :shots, dependent: :destroy
  has_many :characters, through: :shots
  has_many :vehicles, through: :shots
  has_many :effects, dependent: :destroy
  has_many :character_effects, through: :shots
  has_one_attached :image

  scope :active, -> { where(active: true) }

  SORT_ORDER = ["Uber-Boss", "Boss", "PC", "Featured Foe", "Ally", "Mook"]
  DEFAULT_SHOT_COUNT = 3

  def as_json(args={})
    {
      id: id,
      name: name,
      description: description,
      active: active,
      created_at: created_at,
      updated_at: updated_at,
      characters: characters,
      vehicles: vehicles,
      shot_order: shot_order,
      sequence: sequence,
      effects: effects,
      character_effects: character_effects.where("character_effects.character_id IS NOT NULL").group_by { |ce| ce.shot_id },
      vehicle_effects: character_effects.where("character_effects.vehicle_id IS NOT NULL").group_by { |ce| ce.shot_id }
    }
  end

  def current_shot
    shots.maximum(:shot) || 0
  end

  #    return fight.effects.filter((effect: Effect) => {
  #     return shot > 0 && (
  #       (fight.sequence == effect.start_sequence && shot <= effect.start_shot) ||
  #         (fight.sequence == effect.end_sequence && shot > effect.end_shot)
  #     )
  def active_effects
    @current_shot = current_shot
    @active_effects ||= effects.order(:severity).select do |effect|
      @current_shot > 0 &&
        (
          (sequence == effect.start_sequence && current_shot <= effect.start_shot) ||
          (sequence == effect.end_sequence && current_shot > effect.end_shot)
        )
    end
  end

  def shot_order
    shots
      .group_by { |sh| sh.shot }
      .sort_by { |shot, _shot_chars| shot.nil? ? 1000 : -shot.to_i }
      .map { |shot, shot_chars|
        [shot, shot_chars
          .sort_by(&:sort_order)
          .map(&:as_json)
          .flatten
          .compact
        ]
      }.reject { |shot, shot_chars| shot_chars.empty? }
  end

end
