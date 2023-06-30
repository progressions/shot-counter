class Api::V1::MembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_current_party

  def index
    @characters = @party.characters

    render json: @characters
  end

  # Add a character to a party
  def create
    @character = current_campaign.characters.find(params[:character_id])
    @party.characters << @character

    render json: @character
  end

  # Remove a character from a party
  def destroy
    @membership = @party.memberships.find_by(character_id: params[:id])
    @membership.destroy!

    render :ok
  end

  private

  def set_current_party
    @party = current_campaign.parties.find(params[:party_id])
  end
end
