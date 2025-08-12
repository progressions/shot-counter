class UserAutocompleteSerializer < ActiveModel::Serializer
  attributes :id, :name, :email

  def name
    if object.first_name.present? && object.last_name.present?
      "#{object.first_name} #{object.last_name} (#{object.email})"
    else
      object.email
    end
  end
end
