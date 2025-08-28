class Party < ApplicationRecord
  include Broadcastable
  include WithImagekit
  include OnboardingTrackable
  include CacheVersionable

  has_many :memberships, dependent: :destroy
  has_many :characters, through: :memberships
  has_many :vehicles, through: :memberships
  belongs_to :faction, optional: true
  belongs_to :juncture, optional: true
  belongs_to :campaign
  has_one_attached :image
  has_many :image_positions, as: :positionable, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :campaign_id }
  validate :associations_belong_to_same_campaign

  def as_v1_json(options = {})
    {
      id: id,
      name: name,
      description: description,
      faction: faction,
      characters: characters.map { |character|
        {
          id: character.id,
          name: character.name,
          category: "character",
          image_url: character.image.attached? ? character.image.url : nil,
          action_values: character.action_values,
          faction: character.faction,
        }
      },
      vehicles: vehicles.map { |vehicle|
        {
          id: vehicle.id,
          name: vehicle.name,
          category: "vehicle",
          image_url: vehicle.image.attached? ? vehicle.image.url : nil,
          action_values: vehicle.action_values,
          faction: vehicle.faction,
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

    # Check faction
    if faction_id.present? && faction && faction.campaign_id != campaign_id
      errors.add(:faction, "must belong to the same campaign")
    end

  end
end