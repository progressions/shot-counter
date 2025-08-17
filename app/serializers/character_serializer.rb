class CharacterSerializer < ActiveModel::Serializer
  attributes :id, :name, :active, :created_at, :updated_at, :action_values,
             :faction_id, :description, :skills, :category, :image_url,
             :task, :notion_page_id, :wealth, :juncture_id, :schtick_ids,
             :party_ids, :site_ids, :advancement_ids, :weapon_ids, :entity_class, :user_id

  belongs_to :user, serializer: UserLiteSerializer
  belongs_to :faction, serializer: FactionLiteSerializer
  belongs_to :juncture, serializer: JunctureLiteSerializer
  # has_many :schticks, serializer: SchtickSerializer
  # has_many :advancements, serializer: AdvancementSerializer
  # has_many :weapons, through: :carries, serializer: WeaponSerializer
  # has_many :sites, through: :attunements, serializer: SiteSerializer
  # has_many :parties, through: :party_memberships, serializer: PartySerializer
  has_many :image_positions, serializer: ImagePositionSerializer

  def entity_class
    object.class.name
  end

  def image_url
    return nil unless object.image.attached?
    object.image_url
  end
end
