require "bcrypt"

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :confirmable, :recoverable, :lockable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  include BCrypt

  belongs_to :current_campaign, class_name: "Campaign", optional: true
  has_many :campaigns
  has_many :characters
  has_many :vehicles
  has_many :campaign_memberships, dependent: :destroy
  has_many :player_campaigns, through: :campaign_memberships, source: "campaign"
  has_many :invitations
  has_one_attached :image
  validates :email,
    uniqueness: true,
    allow_nil: true,
    format: {
      with: /\A[^@\s]+@[^@.\s]+(?:\.[^@.\s]+)+\z/,
      message: "is invalid"
    }

  def as_json(options = {})
    super(options.merge(
      only: [:id, :email, :first_name, :last_name, :admin, :gamemaster],
      methods: [:image_url, :name],
    ))
  end

  def name
    "#{first_name} #{last_name}".strip
  end

  def password
    @password ||= Password.new(encrypted_password)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.encrypted_password = @password
  end

  def image_url
    image.attached? ? image.url : nil
  end

  def jwt_payload
    super.merge(
      user: {
        email: email,
        admin: admin,
        first_name: first_name,
        last_name: last_name,
        gamemaster: true,
        current_campaign: current_campaign&.id,
        created_at: created_at,
        updated_at: updated_at,
        image_url: image_url
      }
    )
  end
end
