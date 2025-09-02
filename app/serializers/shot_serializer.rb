class ShotSerializer < ActiveModel::Serializer
  attributes :id, :shot, :location, :characters

  def characters
    object[:characters].map do |character|
      ShotDetailSerializer.new(character, scope: object)
    end
  end
end
