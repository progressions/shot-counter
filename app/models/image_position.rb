class ImagePosition < ApplicationRecord
  belongs_to :positionable, polymorphic: true

  enum :context, {
    "desktop_index" => "desktop_index",
    "mobile_index" => "mobile_index",
    "desktop_entity" => "desktop_entity",
    "mobile_entity" => "mobile_entity"
  }

  validates :context, presence: true
  validates :x_position, :y_position, numericality: true
  validates :context, uniqueness: { scope: [:positionable_type, :positionable_id], message: "already exists for this positionable" }
end
