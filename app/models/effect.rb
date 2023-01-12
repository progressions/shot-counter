class Effect < ApplicationRecord
  has_many :fight_characters, dependent: :destroy
  has_many :fights, through: :fight_characters
  belongs_to :user, optional: true

  def as_json(args=nil)
    {
      id: id,
      title: title,
      description: description,
      category: "effect"
    }
  end

  def sort_order
    [0, title]
  end

end
