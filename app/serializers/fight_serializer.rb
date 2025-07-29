class FightSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :image_url, :created_at, :updated_at, :active, :sequence, :actors, :character_ids

  def actors
    object.characters
  end
end
