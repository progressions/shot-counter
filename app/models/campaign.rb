class Campaign < ApplicationRecord
  belongs_to :user
  has_many :fights
  has_many :characters
  has_many :vehicles
  has_many :campaign_memberships
  has_many :players, through: :campaign_memberships, source: "user"
  has_many :invitations
  has_many :schticks
  has_many :weapons
  has_many :parties
  has_many :sites
  has_many :factions
  has_many :junctures
  has_one_attached :image

  validates :name, presence: true, allow_blank: false

  def as_json(args={})
    {
      id: id,
      name: name,
      description: description,
      gamemaster: user,
      players: players,
      invitations: invitations,
    }
  end
end
