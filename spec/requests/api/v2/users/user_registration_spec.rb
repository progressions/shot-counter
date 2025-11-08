require "rails_helper"

RSpec.describe "Api::V2::Users Registration", type: :request do
  before(:each) do
    User.destroy_all
  end

  describe "POST /api/v2/users/register" do
    let(:valid_attributes) do
      {
        email: "newuser@example.com",
        password: "password123",
        password_confirmation: "password123",
        first_name: "John",
        last_name: "Doe"
      }
    end

    context "with valid parameters" do
      it "creates a new user successfully" do
        expect {
          post "/api/v2/users/register", params: { user: valid_attributes }
        }.to change { User.count }.by(1)

        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["message"]).to include("Registration successful")
        expect(body["data"]["email"]).to eq("newuser@example.com")
        expect(body["data"]["first_name"]).to eq("John")
        expect(body["data"]["last_name"]).to eq("Doe")
      end

      it "returns JWT token in Authorization header" do
        post "/api/v2/users/register", params: { user: valid_attributes }
        
        expect(response.headers["Authorization"]).to be_present
        expect(response.headers["Authorization"]).to start_with("Bearer ")
      end

      it "sends confirmation email if confirmable is enabled" do
        post "/api/v2/users/register", params: { user: valid_attributes }
        
        expect(response).to have_http_status(:created)
        # Check that user is created but not confirmed yet
        user = User.last
        expect(user.confirmed?).to be_falsey
        expect(user.confirmation_token).to be_present
      end

      it "creates user with correct attributes" do
        post "/api/v2/users/register", params: { user: valid_attributes }
        
        user = User.last
        expect(user.email).to eq("newuser@example.com")
        expect(user.first_name).to eq("John")
        expect(user.last_name).to eq("Doe")
        expect(user.name).to eq("John Doe")
        expect(user.admin).to be_falsey
        expect(user.gamemaster).to be_truthy
      end
    end

    context "with invalid parameters" do
      it "returns errors for missing required fields" do
        post "/api/v2/users/register", params: { user: { email: "" } }

        expect(response).to have_http_status(:unprocessable_content)
        body = JSON.parse(response.body)
        expect(body["errors"]).to have_key("email")
        expect(body["errors"]).to have_key("password")
        expect(body["errors"]).to have_key("first_name")
        expect(body["errors"]).to have_key("last_name")
      end

      it "returns error for invalid email format" do
        invalid_attributes = valid_attributes.merge(email: "invalid-email")
        
        post "/api/v2/users/register", params: { user: invalid_attributes }

        expect(response).to have_http_status(:unprocessable_content)
        body = JSON.parse(response.body)
        expect(body["errors"]["email"]).to include("is invalid")
      end

      it "returns error for duplicate email" do
        # Create existing user
        User.create!(valid_attributes.merge(confirmed_at: Time.now))

        post "/api/v2/users/register", params: { user: valid_attributes }

        expect(response).to have_http_status(:unprocessable_content)
        body = JSON.parse(response.body)
        expect(body["errors"]["email"]).to include("has already been taken")
      end

      it "returns error for password mismatch" do
        invalid_attributes = valid_attributes.merge(password_confirmation: "different")

        post "/api/v2/users/register", params: { user: invalid_attributes }

        expect(response).to have_http_status(:unprocessable_content)
        body = JSON.parse(response.body)
        expect(body["errors"]["password_confirmation"]).to include("doesn't match Password")
      end

      it "returns error for short password" do
        invalid_attributes = valid_attributes.merge(
          password: "short",
          password_confirmation: "short"
        )

        post "/api/v2/users/register", params: { user: invalid_attributes }

        expect(response).to have_http_status(:unprocessable_content)
        body = JSON.parse(response.body)
        expect(body["errors"]["password"]).to include("is too short (minimum is 8 characters)")
      end

      it "returns error for missing first name" do
        invalid_attributes = valid_attributes.merge(first_name: "")

        post "/api/v2/users/register", params: { user: invalid_attributes }

        expect(response).to have_http_status(:unprocessable_content)
        body = JSON.parse(response.body)
        expect(body["errors"]["first_name"]).to include("can't be blank")
      end

      it "returns error for missing last name" do
        invalid_attributes = valid_attributes.merge(last_name: "")

        post "/api/v2/users/register", params: { user: invalid_attributes }

        expect(response).to have_http_status(:unprocessable_content)
        body = JSON.parse(response.body)
        expect(body["errors"]["last_name"]).to include("can't be blank")
      end
    end

    context "security and rate limiting" do
      it "does not require authentication" do
        post "/api/v2/users/register", params: { user: valid_attributes }
        
        expect(response).to have_http_status(:created)
      end

      it "sanitizes input to prevent XSS" do
        xss_attributes = valid_attributes.merge(
          first_name: "John<script>alert('xss')</script>",
          last_name: "Doe<img src=x onerror=alert('xss')>"
        )

        post "/api/v2/users/register", params: { user: xss_attributes }

        expect(response).to have_http_status(:created)
        user = User.last
        # Verify that HTML tags are stripped out by sanitization
        expect(user.first_name).to eq("John")
        expect(user.last_name).to eq("Doe")
        expect(user.first_name).not_to include("<script>")
        expect(user.last_name).not_to include("<img")
      end
    end

    context "response format consistency" do
      it "follows API v2 response structure" do
        post "/api/v2/users/register", params: { user: valid_attributes }

        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        
        # Check response structure matches existing patterns
        expect(body).to have_key("code")
        expect(body).to have_key("message")
        expect(body).to have_key("data")
        expect(body["code"]).to eq(201)
        expect(body["data"]).to have_key("id")
        expect(body["data"]).to have_key("email")
        expect(body["data"]).to have_key("first_name")
        expect(body["data"]).to have_key("last_name")
        expect(body["data"]).to have_key("entity_class")
        expect(body["data"]["entity_class"]).to eq("User")
      end

      it "includes JWT payload in response" do
        post "/api/v2/users/register", params: { user: valid_attributes }

        body = JSON.parse(response.body)
        expect(body).to have_key("payload")
        expect(body["payload"]).to have_key("jti")
        expect(body["payload"]).to have_key("sub")
        expect(body["payload"]).to have_key("exp")
      end
    end
  end
end