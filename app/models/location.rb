class Location < ApplicationRecord
  has_one :shot, dependent: :nullify

  validates :name, presence: true
  validates :shot, presence: true
  has_one_attached :image

  delegate :character, :vehicle, to: :shot

  def as_json(options = {})
    super(options.merge(include: [:shot]))
  end
end
