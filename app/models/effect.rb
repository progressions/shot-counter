class Effect < ApplicationRecord
  belongs_to :fight
  belongs_to :user, optional: true
  validates :severity, inclusion: { in: %w(error info success warning) }
end
