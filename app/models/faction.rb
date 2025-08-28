class Faction < ApplicationRecord
  include Broadcastable
  include WithImagekit
  include OnboardingTrackable
  include CacheVersionable

  belongs_to :campaign
  has_many :characters
  has_many :vehicles
  has_many :sites
  has_many :junctures
  has_many :parties
  has_many :image_positions, as: :positionable, dependent: :destroy
  has_one_attached :image

  validates :name, presence: true, uniqueness: { scope: :campaign_id }
  validate :associations_belong_to_same_campaign
  after_update :broadcast_campaign_update

  def as_v1_json(args = {})
    {
      id: id,
      name: name,
      description: description,
      active: self.active,
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


  private

  def associations_belong_to_same_campaign
    return unless campaign_id.present?

    # Check characters
    if characters.any? && characters.exists?(["campaign_id != ?", campaign_id])
      errors.add(:characters, "must all belong to the same campaign")
    end

    # Check vehicles
    if vehicles.any? && vehicles.exists?(["campaign_id != ?", campaign_id])
      errors.add(:vehicles, "must all belong to the same campaign")
    end

    # Check parties
    if parties.any? && parties.exists?(["campaign_id != ?", campaign_id])
      errors.add(:parties, "must all belong to the same campaign")
    end

    # Check sites
    if sites.any? && sites.exists?(["campaign_id != ?", campaign_id])
      errors.add(:sites, "must all belong to the same campaign")
    end

    # Check junctures
    if junctures.any? && junctures.exists?(["campaign_id != ?", campaign_id])
      errors.add(:junctures, "must all belong to the same campaign")
    end

  end
end