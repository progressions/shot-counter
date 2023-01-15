class Campaign < ApplicationRecord
  belongs_to :user

  validates :title, presence: true

  def as_json(args={})
    {
      id: id,
      title: title,
      description: description,
      user: user
    }
  end
end
