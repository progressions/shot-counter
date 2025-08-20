class Api::V2::InvitationsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :require_current_campaign, except: [:show, :redeem]
  before_action :require_gamemaster, only: [:index, :create, :destroy, :resend]
  before_action :set_invitation, only: [:show, :destroy, :resend, :redeem]
  
  # GET /api/v2/invitations
  # Returns pending invitations for current campaign
  def index
    @invitations = current_campaign.invitations
                                  .includes(:pending_user, :user)
                                  .order(created_at: :desc)
    
    invitations_data = ActiveModelSerializers::SerializableResource.new(
      @invitations,
      each_serializer: InvitationSerializer,
      adapter: :attributes
    ).serializable_hash
    
    render json: invitations_data
  end
  
  # POST /api/v2/invitations
  # Creates new invitation and sends email
  def create
    @invitation = current_user.invitations.build(invitation_params)
    @invitation.campaign = current_campaign
    @invitation.pending_user = User.find_by(email: @invitation.email)
    
    if @invitation.save
      UserMailer.with(invitation: @invitation).invitation.deliver_later!
      invitation_data = ActiveModelSerializers::SerializableResource.new(
        @invitation,
        serializer: InvitationSerializer,
        adapter: :attributes
      ).serializable_hash
      render json: invitation_data, status: :created
    else
      render json: { errors: @invitation.errors.as_json }, status: :unprocessable_entity
    end
  end
  
  # POST /api/v2/invitations/:id/resend
  # Resends invitation email
  def resend
    UserMailer.with(invitation: @invitation).invitation.deliver_later!
    invitation_data = ActiveModelSerializers::SerializableResource.new(
      @invitation,
      serializer: InvitationSerializer,
      adapter: :attributes
    ).serializable_hash
    render json: invitation_data
  end
  
  # GET /api/v2/invitations/:id
  # Returns invitation details (public endpoint for redemption page)
  def show
    invitation_data = ActiveModelSerializers::SerializableResource.new(
      @invitation,
      serializer: InvitationSerializer,
      adapter: :attributes
    ).serializable_hash
    
    render json: invitation_data
  end
  
  # POST /api/v2/invitations/:id/redeem
  # Redeems invitation and adds user to campaign
  def redeem
    # Check if user already in campaign
    if @invitation.campaign.users.include?(current_user)
      return render json: { error: "Already a member of this campaign" }, status: :conflict
    end
    
    # Add user to campaign
    membership = @invitation.campaign.campaign_memberships.build(user: current_user)
    
    if membership.save
      # Clean up invitation
      @invitation.destroy!
      
      # Broadcast update for real-time UI updates
      BroadcastCampaignUpdateJob.perform_later("Campaign", @invitation.campaign.id)
      
      # Return campaign data
      campaign_data = ActiveModelSerializers::SerializableResource.new(
        @invitation.campaign,
        serializer: CampaignSerializer,
        adapter: :attributes
      ).serializable_hash
      
      render json: { 
        campaign: campaign_data,
        message: "Successfully joined #{@invitation.campaign.name}!"
      }, status: :created
    else
      render json: { errors: membership.errors.as_json }, status: :unprocessable_entity
    end
  end
  
  # DELETE /api/v2/invitations/:id
  # Cancels pending invitation
  def destroy
    @invitation.destroy!
    head :no_content
  end
  
  private
  
  def set_invitation
    if action_name.in?(['show', 'redeem'])
      # For show and redeem actions, find invitation directly (don't scope to current campaign)
      @invitation = Invitation.find(params[:id])
    else
      # For other actions, scope to current campaign
      @invitation = current_campaign.invitations.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Invitation not found" }, status: :not_found
  end
  
  def invitation_params
    return {} unless params[:invitation]
    params.require(:invitation).permit(:email)
  end
  
  def require_gamemaster
    unless current_user.gamemaster? || current_campaign.user_id == current_user.id
      render json: { error: "Unauthorized" }, status: :forbidden
    end
  end
end