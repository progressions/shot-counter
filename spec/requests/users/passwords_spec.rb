require 'rails_helper'

RSpec.describe "Users::Passwords", type: :request do
  let(:user) { User.create!(email: 'test@example.com', first_name: 'Test', last_name: 'User', password: 'password123', confirmed_at: Time.now) }
  let(:valid_token) { user.send_reset_password_instructions }

  before do
    Rails.cache.clear # Clear rate limiting cache
    ActionMailer::Base.deliveries.clear
  end

  describe "POST /users/password (create)" do
    context "with valid email" do
      it "returns success response for existing user" do
        post "/users/password", params: { user: { email: user.email } }
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to include("If your email address exists")
      end

      it "returns success response even for non-existent email (prevents enumeration)" do
        post "/users/password", params: { user: { email: "nonexistent@example.com" } }
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to include("If your email address exists")
      end

      it "sends email for existing user" do
        expect {
          post "/users/password", params: { user: { email: user.email } }
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context "with invalid email format" do
      it "rejects obviously invalid email" do
        post "/users/password", params: { user: { email: "invalid-email" } }
        
        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to eq("Invalid email format")
        expect(JSON.parse(response.body)["field"]).to eq("email")
      end

      it "rejects email that's too long" do
        long_email = "#{'a' * 250}@example.com"
        post "/users/password", params: { user: { email: long_email } }
        
        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to eq("Invalid email format")
      end
    end

    context "rate limiting" do
      before do
        # Don't clear cache for rate limiting tests - we need to accumulate counts
        ActionMailer::Base.deliveries.clear
      end

      it "allows up to 3 requests per hour per email" do
        # Clear rate limiting cache just for this test
        email_key = "password_reset_rate_limit:email:#{user.email.downcase}"
        Rails.cache.delete(email_key)
        
        3.times do
          post "/users/password", params: { user: { email: user.email } }
          expect(response).to have_http_status(:ok)
        end
      end

      it "blocks 4th request per hour per email" do
        # Clear rate limiting cache and make 3 requests first
        email_key = "password_reset_rate_limit:email:#{user.email.downcase}"
        Rails.cache.delete(email_key)
        
        3.times { post "/users/password", params: { user: { email: user.email } } }
        
        post "/users/password", params: { user: { email: user.email } }
        
        expect(response).to have_http_status(:too_many_requests)
        expect(JSON.parse(response.body)["error"]).to include("Too many password reset attempts")
      end
    end
  end

  describe "PUT /users/password (update)" do
    let(:valid_params) do
      {
        user: {
          reset_password_token: valid_token,
          password: "newpassword123",
          password_confirmation: "newpassword123"
        }
      }
    end

    context "with valid token and password" do
      it "successfully resets password" do
        put "/users/password", params: valid_params
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq("Your password has been changed successfully.")
        expect(JSON.parse(response.body)["redirect"]).to eq("/login")
      end

      it "allows user to login with new password" do
        put "/users/password", params: valid_params
        
        user.reload
        expect(user.valid_password?("newpassword123")).to be true
        expect(user.valid_password?("password123")).to be false
      end
    end

    context "with invalid token" do
      it "rejects invalid token" do
        put "/users/password", params: {
          user: {
            reset_password_token: "invalid_token",
            password: "newpassword123",
            password_confirmation: "newpassword123"
          }
        }
        
        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to eq("Password reset token is invalid or has expired")
      end
    end

    context "with weak password" do
      it "rejects password less than 8 characters" do
        put "/users/password", params: {
          user: {
            reset_password_token: valid_token,
            password: "short1",
            password_confirmation: "short1"
          }
        }
        
        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to include("at least 8 characters")
        expect(JSON.parse(response.body)["field"]).to eq("password")
      end

      it "rejects password without letters" do
        put "/users/password", params: {
          user: {
            reset_password_token: valid_token,
            password: "12345678",
            password_confirmation: "12345678"
          }
        }
        
        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to include("contain letters and numbers")
      end

      it "rejects password without numbers" do
        put "/users/password", params: {
          user: {
            reset_password_token: valid_token,
            password: "abcdefgh",
            password_confirmation: "abcdefgh"
          }
        }
        
        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to include("contain letters and numbers")
      end
    end

    context "with mismatched password confirmation" do
      it "rejects when passwords don't match" do
        put "/users/password", params: {
          user: {
            reset_password_token: valid_token,
            password: "newpassword123",
            password_confirmation: "differentpassword123"
          }
        }
        
        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to eq("Password confirmation doesn't match password")
        expect(JSON.parse(response.body)["field"]).to eq("password_confirmation")
      end
    end
  end

  describe "validation helper methods" do
    let(:controller) { Users::PasswordsController.new }

    describe "#valid_email_format?" do
      it "accepts valid email formats" do
        valid_emails = [
          "test@example.com",
          "user.name@example.co.uk"
        ]
        
        valid_emails.each do |email|
          expect(controller.send(:valid_email_format?, email)).to be true
        end
      end

      it "rejects invalid email formats" do
        invalid_emails = [
          "",
          "invalid",
          "@example.com",
          "test@",
          "test@@example.com"
        ]
        
        invalid_emails.each do |email|
          expect(controller.send(:valid_email_format?, email)).to be false
        end
      end
    end

    describe "#valid_password?" do
      it "accepts valid passwords" do
        valid_passwords = ["password123", "MySecure1Pass"]
        
        valid_passwords.each do |password|
          expect(controller.send(:valid_password?, password)).to be true
        end
      end

      it "rejects invalid passwords" do
        invalid_passwords = ["", "short1", "12345678", "password"]
        
        invalid_passwords.each do |password|
          expect(controller.send(:valid_password?, password)).to be false
        end
      end
    end
  end
end