class Campaign < ApplicationRecord
  belongs_to :user
  has_many :fights
  has_many :characters
  has_many :vehicles
  has_many :campaign_memberships
  has_many :players, through: :campaign_memberships, source: "user"
  has_many :invitations

  validates :title, presence: true, allow_blank: false

  def as_json(args={})
    {
      id: id,
      title: title,
      description: description,
      gamemaster: user,
      players: players,
      invitations: invitations,
    }
  end
end
