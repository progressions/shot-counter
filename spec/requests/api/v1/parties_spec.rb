require 'rails_helper'

RSpec.describe "Api::V1::Parties", type: :request do
  let!(:user) { User.create!(email: "email@example.com", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let!(:pirates) { user.campaigns.create!(name: "Pirates") }
  let(:fight) { Fight.create!(name: "Museum Fight", campaign: action_movie) }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }
  let(:serena) { Character.create!(name: "Serena Tessaro", campaign: action_movie) }
  let(:truck) { Vehicle.create!(name: "Truck", campaign: action_movie) }
  let!(:party) { Party.create!(name: "The Party", campaign: action_movie) }
  let!(:gang) { Party.create!(name: "The Gang", campaign: action_movie) }
  let!(:crew) { Party.create!(name: "The Pirate Crew", campaign: pirates) }
  let!(:dragons) { Faction.create!(name: "The Dragons", campaign: action_movie) }
  let!(:ascended) { Faction.create!(name: "Ascended", campaign: action_movie) }
  let(:headers) { Devise::JWT::TestHelpers.auth_headers({}, user) }

  before(:each) do
    set_current_campaign(user, action_movie)
  end

  describe "GET /index" do
    it "returns parties" do
      get "/api/v1/parties", headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].length).to eq(2)
      expect(body["parties"][0]["name"]).to eq("The Party")
    end

    it "returns parties matching a search string" do
      get "/api/v1/parties?search=gang", headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].length).to eq(1)
      expect(body["parties"][0]["name"]).to eq("The Gang")
    end

    it "returns parties by faction_id" do
      party.faction = dragons
      party.save!
      get "/api/v1/parties?faction_id=#{dragons.id}", headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["parties"].length).to eq(1)
      expect(body["parties"][0]["name"]).to eq("The Party")
    end

    it "returns factions for parties" do
      gang.faction = ascended
      gang.save!
      party.faction = dragons
      party.save!
      get "/api/v1/parties", headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["Ascended", "The Dragons"])
    end
  end

  describe "POST /fight" do
    it "adds a party to a fight" do
      party.characters << brick
      party.characters << serena
      party.vehicles << truck
      post "/api/v1/parties/#{party.id}/fight/#{fight.id}", headers: headers
      expect(response).to have_http_status(:success)
      expect(fight.characters.reload).to include(brick, serena)
      expect(fight.shot_order).to eq([[0, [brick, serena, truck]]])
      expect(fight.vehicles.reload).to include(truck)
    end

    it "doesn't double-add characters" do
      party.characters << brick
      party.characters << serena
      fight.shots.create!(character: brick, shot: 5)
      fight.shots.create!(character: serena, shot: 5)
      post "/api/v1/parties/#{party.id}/fight/#{fight.id}", headers: headers
      expect(response).to have_http_status(:success)
      expect(fight.characters.reload).to include(brick, serena)
      expect(fight.shot_order).to eq([[5, [brick, serena]]])
    end

    it "creates a party with a faction" do
      post "/api/v1/parties", params: { party: { name: "The Dragons", faction_id: dragons.id } }, headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Dragons")
      expect(body["faction"]["name"]).to eq("The Dragons")
    end
  end

  describe "GET /show" do
    it "returns a single party" do
      get "/api/v1/parties/#{party.id}", headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Party")
    end
  end

  describe "POST /create" do
    it "creates a party" do
      expect {
        post "/api/v1/parties", params: { party: { name: "The Party" } }, headers: headers
      }.to change { Party.count }.by(1)
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Party")
    end
  end

  describe "PUT /update" do
    it "updates a party" do
      put "/api/v1/parties/#{party.id}", params: { party: { name: "The Dragons" } }, headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Dragons")
    end

    it "adds a faction" do
      put "/api/v1/parties/#{party.id}", params: { party: { faction_id: dragons.id } }, headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["faction"]["name"]).to eq("The Dragons")
    end
  end

  describe "DELETE /destroy" do
    it "deletes a party" do
      expect {
        delete "/api/v1/parties/#{party.id}", headers: headers
      }.to change { Party.count }.by(-1)
      expect(response).to have_http_status(:success)
    end
  end
end
