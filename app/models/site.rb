class Site < ApplicationRecord
  belongs_to :campaign
  belongs_to :faction, optional: true
  has_many :attunements, dependent: :destroy
  has_many :characters, through: :attunements

  validates :name, presence: true, uniqueness: { scope: :campaign_id }

  def as_json(args = {})
    super(args.merge(include: :faction))
  end
end
