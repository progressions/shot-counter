class CharacterSerializer < ActiveModel::Serializer
  attributes :id, :name, :active, :created_at, :updated_at, :action_values,
             :faction_id, :description, :skills, :category, :image_url,
             :task, :notion_page_id, :wealth, :juncture_id

  belongs_to :user, serializer: UserSerializer
  belongs_to :faction, serializer: FactionSerializer
  belongs_to :juncture, serializer: JunctureSerializer
  has_many :schticks, serializer: SchtickSerializer
  has_many :advancements, serializer: AdvancementSerializer
  has_many :carries, serializer: CarrySerializer
  has_many :weapons, through: :carries, serializer: WeaponSerializer
  has_many :attunements, serializer: AttunementSerializer
  has_many :sites, through: :attunements, serializer: SiteSerializer
end
