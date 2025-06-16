class FightEvent < ApplicationRecord
  belongs_to :fight, touch: true
  validates :event_type, :description, presence: true

  def as_json(options = {})
    {
      id: id,
      fight_id: fight_id,
      event_type: event_type,
      description: description,
      created_at: created_at.strftime("%Y-%m-%d %H:%M:%S"),
      updated_at: updated_at.strftime("%Y-%m-%d %H:%M:%S")
    }
  end
end
