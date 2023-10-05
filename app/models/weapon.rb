class Weapon < ApplicationRecord
  belongs_to :campaign
  has_many :carries
  has_many :characters, through: :carries
  has_one_attached :image

  validates :name, presence: true, uniqueness: { scope: :campaign_id }
  validates :damage, presence: true

  def as_json(args = {})
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
      image_url: image.attached? ? image.url : nil
    }
  end
end
