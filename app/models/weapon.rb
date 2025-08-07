class Weapon < ApplicationRecord
  include Broadcastable
  include WithImagekit

  belongs_to :campaign
  has_many :carries
  has_many :characters, through: :carries
  has_many :image_positions, as: :positionable, dependent: :destroy
  has_one_attached :image

  validates :name, presence: true, uniqueness: { scope: :campaign_id }
  validates :damage, presence: true
  after_update :broadcast_campaign_update

  def as_v1_json(args = {})
    {
      id: id,
      name: name,
      description: description,
      damage: damage,
      concealment: concealment,
      reload_value: reload_value,
      category: category,
      juncture: juncture,
      mook_bonus: mook_bonus,
      kachunk: kachunk,
      image_url: image_url
    }
  end
end
