class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :campaigns
  has_many :characters
  has_many :vehicles
  has_many :campaign_memberships
  has_many :player_campaigns, through: :campaign_memberships, source: "campaign"
  has_many :invitations

  def jwt_payload
    super.merge(
      "something" => "nothing"
    )
  end
end
