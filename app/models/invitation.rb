class Invitation < ApplicationRecord
  belongs_to :campaign
  belongs_to :user

  validates :email, uniqueness: { scope: :campaign_id }, allow_nil: true

  validate :ensure_new_player

  def ensure_new_player
    if (campaign&.players&.find_by(email: email))
      errors.add(:email, "is already a player")
    end

    if (campaign&.user&.email == email)
      errors.add(:email, "is the gamemaster")
    end
  end
end
