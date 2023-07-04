class Api::V1::MembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_current_party

  def index
    render json: @party
  end

  # Add a character to a party
  def create
    if params[:character_id].present?
      @character = current_campaign.characters.find(params[:character_id])
      @party.characters << @character
    end

    if params[:vehicle_id].present?
      @vehicle = current_campaign.vehicles.find(params[:vehicle_id])
      @party.vehicles << @vehicle
    end

    render json: @party
  end

  # Remove a character from a party
  def remove_character
    @membership = @party.memberships.find_by(character_id: params[:id])

    if @membership.nil?
      render json: { error: "Membership not found" }, status: :not_found
      return
    end

    @membership.destroy!

    render :ok
  end

  def remove_vehicle
    @membership = @party.memberships.find_by(vehicle_id: params[:id])

    if @membership.nil?
      render json: { error: "Membership not found" }, status: :not_found
      return
    end

    @membership.destroy!

    render :ok
  end

  private

  def set_current_party
    @party = current_campaign.parties.find(params[:party_id])
  end
end
