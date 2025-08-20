class CampaignIndexLiteSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :active, :created_at, :updated_at,
             :image_url, :gamemaster_id, :entity_class,
             :characters_count, :vehicles_count, :user_ids

  def characters_count
    # Use size instead of count to work with preloaded associations if available
    object.characters.size
  end

  def vehicles_count
    # Use size instead of count to work with preloaded associations if available  
    object.vehicles.size
  end

  def gamemaster_id
    object.user_id
  end

  def entity_class
    'Campaign'
  end

  def user_ids
    # Get user IDs from campaign memberships
    object.user_ids
  end
end