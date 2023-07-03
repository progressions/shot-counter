require "rails_helper"

RSpec.describe "Api::V1::Actors", type: :request do
  let!(:user) { User.create!(email: "email@example.com", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(title: "Action Movie") }
  let(:serena) { Character.create!(name: "Serena Tessaro", campaign: action_movie) }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }
  let(:shing) { Character.create!(name: "Ugly Shing", campaign: action_movie) }
  let(:headers) { Devise::JWT::TestHelpers.auth_headers({}, user) }
  let!(:fight) { action_movie.fights.create!(name: "Fight") }
  let!(:fight_brick) { FightCharacter.create!(fight: fight, character: brick, shot: 10) }
  let!(:fight_shing) { FightCharacter.create!(fight: fight, character: shing, shot: 15) }

  before(:each) do
    set_current_campaign(user, action_movie)
  end

  describe "GET /api/v1/fights/:fight_id/actors" do
    it "returns a list of actors" do
      get "/api/v1/fights/#{fight.id}/actors", headers: headers

      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body.map { |a| a["name"] }).to eq(["Brick Manly", "Ugly Shing"])
    end
  end

  describe "POST /api/v1/fights/:id/actors/:character_id/add" do
    it "adds a character to a fight" do
      post "/api/v1/fights/#{fight.id}/actors/#{serena.id}/add", headers: headers, params: { character: { current_shot: 12 } }

      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Serena Tessaro")
      expect(fight.reload.characters.order(:name).map(&:name)).to eq(["Brick Manly", "Serena Tessaro", "Ugly Shing"])
    end
  end

  describe "POST /api/v1/fights/:id/actors/:character_id/act" do
    it "acts a character" do
      patch "/api/v1/fights/#{fight.id}/actors/#{brick.id}/act", headers: headers, params: { shots: 3 }

      expect(response).to have_http_status(200)
      expect(fight_brick.reload.shot).to eq(7)
    end
  end

  describe "GET /api/v1/fights/:id/actors/:character_id" do
    it "returns a character" do
      get "/api/v1/fights/#{fight.id}/actors/#{brick.id}", headers: headers

      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly")
    end
  end

  describe "PATCH /api/v1/fights/:id/actors/:character_id/reveal" do
    it "reveals a character" do
      fight_brick.update(shot: nil)
      patch "/api/v1/fights/#{fight.id}/actors/#{brick.id}/reveal", headers: headers

      expect(response).to have_http_status(200)
      expect(fight_brick.reload.shot).to eq(0)
    end
  end

  describe "PATCH /api/v1/fights/:id/actors/:character_id/hide" do
    it "hides a character" do
      patch "/api/v1/fights/#{fight.id}/actors/#{brick.id}/hide", headers: headers

      expect(response).to have_http_status(200)
      expect(fight_brick.reload.shot).to eq(nil)
    end
  end

  describe "DELETE /api/v1/fights/:id/actors/:character_id" do
    it "removes a character from a fight" do
      delete "/api/v1/fights/#{fight.id}/actors/#{brick.id}", headers: headers

      expect(response).to have_http_status(200)
      expect(fight.reload.characters.order(:name).map(&:name)).to eq(["Ugly Shing"])
    end
  end
end