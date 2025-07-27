class AttunementSerializer < ActiveModel::Serializer
  attributes :id
  belongs_to :site, serializer: SiteSerializer
end
