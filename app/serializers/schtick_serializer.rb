class SchtickSerializer < ActiveModel::Serializer
  attributes :id, :name, :category, :path, :image_url

  def image_url
    object.image.attached? ? Rails.application.routes.url_helpers.rails_blob_url(object.image_attachment.blob, only_path: true) : nil
  end
end
