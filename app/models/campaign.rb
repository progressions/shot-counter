class Campaign < ApplicationRecord
  belongs_to :user
  has_many :fights

  validates :title, presence: true, allow_blank: false

  def as_json(args={})
    {
      id: id,
      title: title,
      description: description,
      user: user
    }
  end
end
