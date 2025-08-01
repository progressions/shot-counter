class ImagePositionSerializer < ActiveModel::Serializer
  attributes :id, :context, :x_position, :y_position, :style_overrides
end
