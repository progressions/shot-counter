class Invitation < ApplicationRecord
  belongs_to :campaign
  belongs_to :user
  belongs_to :pending_user, class_name: "User", optional: true

  validates :email,
    uniqueness: { scope: :campaign_id },
    allow_nil: true,
    format: {
      with: /\A[^@\s]+@[^@.\s]+(?:\.[^@.\s]+)+\z/,
      message: "is invalid"
    }

  validate :ensure_count_or_email
  validate :ensure_new_player
  validate :valid_count

  before_validation :update_remaining_count

  def as_json(args={})
    {
      id: id,
      email: email,
      maximum_count: maximum_count,
      remaining_count: remaining_count,
      gamemaster: user,
      campaign: {
        id: campaign.id,
        name: campaign.name
      },
      pending_user: {
        id: pending_user&.id,
        email: pending_user&.email
      }
    }
  end

  private

  def ensure_count_or_email
    if self.email && self.maximum_count
      errors.add(:email, "must not be present if maximum_count is set")
      errors.add(:maximum_count, "must not be present if email is set")
      return
    end
    if !self.email && !self.maximum_count
      errors.add(:email, "must be present if maximum_count is not set")
      errors.add(:maximum_count, "must be present if email is not set")
    end
  end

  def valid_count
    if self.maximum_count && (self.remaining_count.to_i > self.maximum_count)
      errors.add(:remaining_count, "cannot exceed maximum_count")
    end
  end

  def update_remaining_count
    if self.maximum_count
      self.remaining_count ||= self.maximum_count
    end
  end

  def ensure_new_player
    if (campaign&.players&.find_by(email: email))
      errors.add(:email, "is already a player")
    end

    if (campaign&.user&.email == email)
      errors.add(:email, "is the gamemaster")
    end
  end
end
