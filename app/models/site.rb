class Site < ApplicationRecord
  include Broadcastable
  include WithImagekit
  include OnboardingTrackable

  belongs_to :campaign
  belongs_to :faction, optional: true
  belongs_to :juncture, optional: true
  has_many :attunements, dependent: :destroy
  has_many :characters, through: :attunements
  has_many :image_positions, as: :positionable, dependent: :destroy
  has_one_attached :image

  validates :name, presence: true, uniqueness: { scope: :campaign_id }
  after_update :broadcast_campaign_update

  def as_v1_json(args = {})
    {
      id: id,
      name: name,
      description: description,
      faction: faction,
      secret: self.secret,
      created_at: created_at,
      updated_at: updated_at,
      characters: characters.map { |character|
        {
          id: character.id,
          name: character.name,
          image_url: character.image_url,
        }
      },
      image_url: image_url
    }
  end
end
