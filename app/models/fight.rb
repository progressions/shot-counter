class Fight < ApplicationRecord
  belongs_to :campaign
  has_many :fight_characters, dependent: :destroy
  has_many :characters, through: :fight_characters
  has_many :vehicles, through: :fight_characters
  has_many :effects, dependent: :destroy
  has_many :character_effects, through: :fight_characters

  scope :active, -> { where(active: true) }

  SORT_ORDER = ["Uber-Boss", "PC", "Boss", "Featured Foe", "Ally", "Mook"]
  DEFAULT_SHOT_COUNT = 3

  def as_json(args)
    {
      id: id,
      name: name,
      active: active,
      created_at: created_at,
      updated_at: updated_at,
      characters: characters,
      vehicles: vehicles,
      shot_order: shot_order,
      sequence: sequence,
      effects: effects,
      character_effects: character_effects.group_by { |ce| ce.character_id }
    }
  end

  def current_shot
    fight_characters.maximum(:shot) || 0
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
    fight_characters
      .group_by { |fc| fc.shot }
      .sort_by { |shot, fight_chars| -shot.to_i }
      .map { |shot, fight_chars|
        [shot, fight_chars
                 .map { |fc| fc.character || fc.vehicle }
                 .compact
                 .sort_by(&:sort_order)
        ]
      }
  end

end
