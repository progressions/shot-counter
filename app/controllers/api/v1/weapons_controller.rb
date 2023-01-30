class Api::V1::WeaponsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  private

  def weapon_params
    params.require(:weapon).permit(:name, :damage, :concealment, :reload)
  end
end
