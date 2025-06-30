require 'rails_helper'

RSpec.describe "Api::V1::Factions", type: :request do
  let(:gamemaster) { User.create!(email: "gamemaster@example.com", confirmed_at: Time.now, gamemaster: true) }
  let(:player) { User.create!(email: "player@example.com", confirmed_at: Time.now, gamemaster: false) }
  let(:campaign) { gamemaster.campaigns.create!(name: "Adventure") }
  let(:dragons) { campaign.factions.create!(name: "The Dragons", active: true) }
  let(:ascended) { campaign.factions.create!(name: "The Ascended", active: true) }
  let(:inactive_faction) { campaign.factions.create!(name: "The Forgotten", active: false) }
  let(:brick) { Character.create!(name: "Brick Manly", action_values: { "Type" => "PC" }, faction_id: dragons.id, campaign_id: campaign.id) }
  let(:headers) { Devise::JWT::TestHelpers.auth_headers({}, gamemaster) }
  let(:player_headers) { Devise::JWT::TestHelpers.auth_headers({}, player) }

  before(:each) do
    set_current_campaign(gamemaster, campaign)
    set_current_campaign(player, campaign)
  end

  describe "GET /api/v1/factions" do
    before { dragons; ascended; inactive_faction }

    it "returns unauthorized for unauthenticated users" do
      get "/api/v1/factions", headers: {}
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns active factions sorted alphabetically" do
      get "/api/v1/factions", headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
    end

    context "when show_all=true and user is gamemaster" do
      it "returns all factions" do
        get "/api/v1/factions", params: { show_all: "true" }, headers: headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons", "The Forgotten"])
      end
    end

    context "when show_all=true and user is not gamemaster" do
      it "returns only active factions" do
        get "/api/v1/factions", params: { show_all: "true" }, headers: player_headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended", "The Dragons"])
      end
    end

    context "with search parameter" do
      it "filters factions by name" do
        get "/api/v1/factions", params: { search: "Dragon" }, headers: headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["factions"].map { |f| f["name"] }).to eq(["The Dragons"])
      end
    end

    context "with character_id parameter" do
      it "excludes factions associated with the character" do
        get "/api/v1/factions", params: { character_id: brick.id }, headers: headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["factions"].map { |f| f["name"] }).to eq(["The Ascended"])
      end

      it "returns not found for invalid character_id" do
        get "/api/v1/factions", params: { character_id: 999 }, headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with pagination" do
      before { 15.times { |i| campaign.factions.create!(name: "Faction #{i}", active: true) } }

      it "paginates results" do
        get "/api/v1/factions", params: { per_page: 5, page: 2 }, headers: headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["factions"].size).to eq(5)
        expect(body["meta"]["current_page"]).to eq(2)
        expect(body["meta"]["total_pages"]).to be > 1
      end
    end
  end

  describe "GET /api/v1/factions/:id" do
    let(:faction) { campaign.factions.create!(name: "The Fallen") }

    it "returns unauthorized for unauthenticated users" do
      get "/api/v1/factions/#{faction.id}", headers: {}
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns the faction" do
      get "/api/v1/factions/#{faction.id}", headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Fallen")
    end

    it "returns not found for invalid faction" do
      get "/api/v1/factions/999", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/factions" do
    it "returns unauthorized for unauthenticated users" do
      post "/api/v1/factions", headers: {}
      expect(response).to have_http_status(:unauthorized)
    end

    it "creates a new faction" do
      post "/api/v1/factions", params: { faction: { name: "The Fallen", description: "A new faction" } }, headers: headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Fallen")
      expect(body["description"]).to eq("A new faction")
    end

    it "returns unprocessable entity for invalid params" do
      post "/api/v1/factions", params: { faction: { name: "" } }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Name can't be blank")
    end
  end

  describe "PATCH /api/v1/factions/:id" do
    let(:faction) { campaign.factions.create!(name: "The Fallen") }

    it "returns unauthorized for unauthenticated users" do
      patch "/api/v1/factions/#{faction.id}", headers: {}
      expect(response).to have_http_status(:unauthorized)
    end

    it "updates the faction" do
      patch "/api/v1/factions/#{faction.id}", params: { faction: { name: "The Fallen Ones", active: false } }, headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("The Fallen Ones")
      expect(body["active"]).to eq(false)
    end

    it "returns unprocessable entity for invalid params" do
      patch "/api/v1/factions/#{faction.id}", params: { faction: { name: "" } }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Name can't be blank")
    end

    it "returns not found for invalid faction" do
      patch "/api/v1/factions/999", params: { faction: { name: "The Fallen Ones" } }, headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/factions/:id" do
    let(:faction) { campaign.factions.create!(name: "The Fallen") }

    it "returns unauthorized for unauthenticated users" do
      delete "/api/v1/factions/#{faction.id}", headers: {}
      expect(response).to have_http_status(:unauthorized)
    end

    it "deletes the faction" do
      delete "/api/v1/factions/#{faction.id}", headers: headers
      expect(response).to have_http_status(:ok)
      expect(Faction.find_by(id: faction.id)).to be_nil
    end

    it "returns not found for invalid faction" do
      delete "/api/v1/factions/999", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/factions/:id/image" do
    let(:faction) { campaign.factions.create!(name: "The Fallen") }

    it "returns unauthorized for unauthenticated users" do
      delete "/api/v1/factions/#{faction.id}/image", headers: {}
      expect(response).to have_http_status(:unauthorized)
    end

    context "when faction has an image" do
      before do
        # Attach image using DiskService-compatible method
        faction.image.attach(
          io: StringIO.new("fake image content"),
          filename: "test.jpg",
          content_type: "image/jpeg"
        )
        faction.save!
        # Mock ImageKit-specific method to prevent delete_ik_file error
        allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
      end

      it "removes the image" do
        expect(faction.image).to be_attached
        delete "/api/v1/factions/#{faction.id}/image", headers: headers
        expect(response).to have_http_status(:success)
        expect(faction.reload.image).not_to be_attached
      end
    end

    it "returns success when no image is attached" do
      expect(faction.image).not_to be_attached
      delete "/api/v1/factions/#{faction.id}/image", headers: headers
      expect(response).to have_http_status(:success)
    end

    it "returns not found for invalid faction" do
      delete "/api/v1/factions/999/image", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
