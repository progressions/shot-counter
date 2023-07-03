class Effect < ApplicationRecord
  belongs_to :fight
  belongs_to :user, optional: true

  validates :severity, presence: true, inclusion: { in: %w(error info success warning) }
end
