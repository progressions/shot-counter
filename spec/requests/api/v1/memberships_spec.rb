require 'rails_helper'

RSpec.describe "Api::V1::Memberships", type: :request do
  let!(:user) { User.create!(email: "email@example.com", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(title: "Action Movie") }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }
  let!(:party) { Party.create!(name: "The Party", campaign: action_movie) }
  let(:headers) { Devise::JWT::TestHelpers.auth_headers({}, user) }

  before(:each) do
    set_current_campaign(user, action_movie)
    party.characters << brick
  end

  describe "GET /index" do
    it "returns memberships" do
      get "/api/v1/parties/#{party.id}/memberships", headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body.length).to eq(1)
      expect(body[0]["name"]).to eq("Brick Manly")
    end
  end

  describe "POST /create" do
    it "creates a membership" do
      expect {
        post "/api/v1/parties/#{party.id}/memberships", params: { character_id: brick.id }, headers: headers
      }.to change { party.characters.count }.by(1)
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly")
    end
  end

  describe "DELETE /destroy" do
    it "deletes a membership" do
      expect {
        delete "/api/v1/parties/#{party.id}/memberships/#{brick.id}", headers: headers
      }.to change { party.characters.count }.by(-1)
      expect(response).to have_http_status(:success)
      expect(brick.reload).to eq(brick)
    end
  end
end
