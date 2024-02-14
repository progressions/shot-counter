class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :confirmable, :recoverable, :lockable,
         :jwt_authenticatable, jwt_revocation_strategy: self

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


  def jwt_payload
    super.merge(
      email: email,
      admin: admin,
      first_name: first_name,
      last_name: last_name,
      gamemaster: true,
      created_at: created_at,
      updated_at: updated_at
    )
  end
end
