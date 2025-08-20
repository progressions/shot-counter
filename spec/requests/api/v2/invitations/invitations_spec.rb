require "rails_helper"

RSpec.describe "Api::V2::Invitations", type: :request do
  before(:each) do
    allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
    # Skip cleanup for now - focus on controller functionality
    # User.destroy_all
    # Campaign.destroy_all
    # Character.destroy_all
    
    # Create users with unique emails
    timestamp = Time.now.to_i
    @gamemaster = User.create!(
      email: "gamemaster#{timestamp}@example.com",
      gamemaster: true,
      confirmed_at: Time.now,
      first_name: "Game",
      last_name: "Master"
    )
    @player = User.create!(
      email: "player#{timestamp}@example.com", 
      confirmed_at: Time.now,
      first_name: "Player",
      last_name: "One"
    )
    @other_gamemaster = User.create!(
      email: "other#{timestamp}@example.com",
      gamemaster: true,
      confirmed_at: Time.now,
      first_name: "Other",
      last_name: "GM"
    )
    
    # Create campaigns
    @campaign = @gamemaster.campaigns.create!(
      name: "Test Campaign",
      description: "Campaign for testing invitations"
    )
    @other_campaign = @other_gamemaster.campaigns.create!(
      name: "Other Campaign",
      description: "Another campaign"
    )
    
    # Set up auth headers
    @gamemaster_headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    @player_headers = Devise::JWT::TestHelpers.auth_headers({}, @player)
    @other_gamemaster_headers = Devise::JWT::TestHelpers.auth_headers({}, @other_gamemaster)
    
    # Set current campaign for gamemaster
    set_current_campaign(@gamemaster, @campaign)
    set_current_campaign(@other_gamemaster, @other_campaign)
  end

  describe "POST /api/v2/invitations" do
    context "as gamemaster" do
      it "creates invitation and sends email" do
        expect {
          post "/api/v2/invitations", 
               params: { invitation: { email: "newplayer@example.com" } },
               headers: @gamemaster_headers
        }.to change { Invitation.count }.by(1)
          .and have_enqueued_job(ActionMailer::MailDeliveryJob)
        
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["email"]).to eq("newplayer@example.com")
        expect(body["gamemaster"]["email"]).to eq(@gamemaster.email)
        expect(body["campaign"]["id"]).to eq(@campaign.id)
        expect(body["created_at"]).to be_present
      end

      it "associates existing user as pending_user" do
        post "/api/v2/invitations",
             params: { invitation: { email: @player.email } },
             headers: @gamemaster_headers
        
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["pending_user"]["email"]).to eq(@player.email)
        expect(body["pending_user"]["id"]).to eq(@player.id)
      end

      it "prevents duplicate invitations" do
        @campaign.invitations.create!(
          user: @gamemaster,
          email: "existing@example.com"
        )
        
        post "/api/v2/invitations",
             params: { invitation: { email: "existing@example.com" } },
             headers: @gamemaster_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["errors"]["email"]).to include("has already been taken")
      end

      it "prevents inviting existing members" do
        @campaign.campaign_memberships.create!(user: @player)
        
        post "/api/v2/invitations",
             params: { invitation: { email: @player.email } },
             headers: @gamemaster_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["errors"]["email"]).to include("is already a player")
      end

      it "prevents inviting the gamemaster" do
        post "/api/v2/invitations",
             params: { invitation: { email: @gamemaster.email } },
             headers: @gamemaster_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["errors"]["email"]).to include("is the gamemaster")
      end

      it "validates email format" do
        post "/api/v2/invitations",
             params: { invitation: { email: "invalid-email" } },
             headers: @gamemaster_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["errors"]["email"]).to include("is invalid")
      end

      it "requires email parameter" do
        post "/api/v2/invitations",
             params: { invitation: {} },
             headers: @gamemaster_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["errors"]["email"]).to include("must be present if maximum_count is not set")
      end
    end

    context "as player" do
      it "returns forbidden" do
        set_current_campaign(@player, @campaign)
        post "/api/v2/invitations",
             params: { invitation: { email: "someone@example.com" } },
             headers: @player_headers
        
        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Unauthorized")
      end
    end

    context "without current campaign" do
      it "returns internal server error" do
        # Clear current campaign
        set_current_campaign(@gamemaster, nil)
        
        post "/api/v2/invitations",
             params: { invitation: { email: "someone@example.com" } },
             headers: @gamemaster_headers
        
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end

  describe "GET /api/v2/invitations" do
    before do
      @invitation1 = @campaign.invitations.create!(
        user: @gamemaster,
        email: "player1@example.com"
      )
      @invitation2 = @campaign.invitations.create!(
        user: @gamemaster,
        email: "player2@example.com",
        pending_user: @player
      )
      # Create invitation in other campaign (should not appear)
      @other_campaign.invitations.create!(
        user: @other_gamemaster,
        email: "other@example.com"
      )
    end

    context "as gamemaster" do
      it "returns campaign invitations" do
        get "/api/v2/invitations", headers: @gamemaster_headers
        
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body.length).to eq(2)
        
        emails = body.map { |i| i["email"] }
        expect(emails).to contain_exactly("player1@example.com", "player2@example.com")
        
        # Check serialization
        invitation_with_pending = body.find { |i| i["email"] == "player2@example.com" }
        expect(invitation_with_pending["pending_user"]["email"]).to eq(@player.email)
        expect(invitation_with_pending["gamemaster"]["email"]).to eq(@gamemaster.email)
        expect(invitation_with_pending["campaign"]["id"]).to eq(@campaign.id)
      end

      it "orders invitations by created_at desc" do
        # Wait a bit and create another invitation
        sleep(0.1)
        @invitation3 = @campaign.invitations.create!(
          user: @gamemaster,
          email: "player3@example.com"
        )
        
        get "/api/v2/invitations", headers: @gamemaster_headers
        
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body.first["email"]).to eq("player3@example.com")
      end
    end

    context "as player" do
      it "returns forbidden" do
        set_current_campaign(@player, @campaign)
        get "/api/v2/invitations", headers: @player_headers
        
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /api/v2/invitations/:id/resend" do
    before do
      @invitation = @campaign.invitations.create!(
        user: @gamemaster,
        email: "player@example.com"
      )
    end

    context "as gamemaster" do
      it "resends invitation email" do
        expect {
          post "/api/v2/invitations/#{@invitation.id}/resend",
               headers: @gamemaster_headers
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
        
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["email"]).to eq("player@example.com")
      end

      it "returns not found for invalid invitation" do
        post "/api/v2/invitations/invalid-id/resend",
             headers: @gamemaster_headers
        
        expect(response).to have_http_status(:not_found)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Invitation not found")
      end

      it "returns not found for invitation from other campaign" do
        other_invitation = @other_campaign.invitations.create!(
          user: @other_gamemaster,
          email: "other@example.com"
        )
        
        post "/api/v2/invitations/#{other_invitation.id}/resend",
             headers: @gamemaster_headers
        
        expect(response).to have_http_status(:not_found)
      end
    end

    context "as player" do
      it "returns forbidden" do
        set_current_campaign(@player, @campaign)
        post "/api/v2/invitations/#{@invitation.id}/resend",
             headers: @player_headers
        
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE /api/v2/invitations/:id" do
    before do
      @invitation = @campaign.invitations.create!(
        user: @gamemaster,
        email: "player@example.com"
      )
    end

    context "as gamemaster" do
      it "cancels invitation" do
        expect {
          delete "/api/v2/invitations/#{@invitation.id}",
                 headers: @gamemaster_headers
        }.to change { Invitation.count }.by(-1)
        
        expect(response).to have_http_status(:no_content)
        expect(response.body).to be_blank
      end

      it "returns not found for invalid invitation" do
        delete "/api/v2/invitations/invalid-id",
               headers: @gamemaster_headers
        
        expect(response).to have_http_status(:not_found)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Invitation not found")
      end

      it "returns not found for invitation from other campaign" do
        other_invitation = @other_campaign.invitations.create!(
          user: @other_gamemaster,
          email: "other@example.com"
        )
        
        delete "/api/v2/invitations/#{other_invitation.id}",
               headers: @gamemaster_headers
        
        expect(response).to have_http_status(:not_found)
      end
    end

    context "as player" do
      it "returns forbidden" do
        set_current_campaign(@player, @campaign)
        delete "/api/v2/invitations/#{@invitation.id}",
               headers: @player_headers
        
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "authorization" do
    context "without authentication" do
      it "requires authentication for all endpoints" do
        post "/api/v2/invitations", params: { invitation: { email: "test@example.com" } }
        expect(response).to have_http_status(:unauthorized)
        
        get "/api/v2/invitations"
        expect(response).to have_http_status(:unauthorized)
        
        post "/api/v2/invitations/123/resend"
        expect(response).to have_http_status(:unauthorized)
        
        delete "/api/v2/invitations/123"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end