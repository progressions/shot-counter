require "rails_helper"

RSpec.describe "Api::V1::FightEvents", type: :request do
  let!(:user) { User.create!(email: "email@example.com", first_name: "Test", last_name: "User", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let(:serena) { Character.create!(name: "Serena Tessaro", campaign: action_movie) }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }
  let(:shing) { Character.create!(name: "Ugly Shing", campaign: action_movie) }
  let(:grunts) { Character.create!(name: "Grunts", action_values: { "Type" => "Mook", "Wounds" => 25 }, campaign: action_movie) }
  let(:headers) { Devise::JWT::TestHelpers.auth_headers({}, user) }
  let!(:fight) { action_movie.fights.create!(name: "Fight") }
  let!(:brick_shot) { Shot.create!(fight: fight, character: brick, shot: 10) }
  let!(:shing_shot) { Shot.create!(fight: fight, character: shing, shot: 15) }

  before(:each) do
    set_current_campaign(user, action_movie)
  end

  describe "GET /api/v1/fights/:fight_id/fight_events" do
    it "returns a list of fight events" do
      # Create some fight events

      fight.fight_events.create!(event_type: "attack", description: "Brick attacks Shing and hits, doing 5 Wounds")
      fight.fight_events.create!(event_type: "attack", description: "Shing attacks Brick and misses")

      get "/api/v1/fights/#{fight.id}/fight_events", headers: headers

      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)

      expect(body.size).to eq(2)
      expect(body[0]["event_type"]).to eq("attack")
      expect(body[0]["description"]).to eq("Brick attacks Shing and hits, doing 5 Wounds")
      expect(body[1]["event_type"]).to eq("attack")
      expect(body[1]["description"]).to eq("Shing attacks Brick and misses")
    end

    it "returns an empty list if no fight events exist" do
      get "/api/v1/fights/#{fight.id}/fight_events", headers: headers

      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)

      expect(body.size).to eq(0)
    end
  end

  describe "POST /api/v1/fights/:fight_id/fight_events" do
    it "creates a new fight event" do
      post "/api/v1/fights/#{fight.id}/fight_events", headers: headers, params: {
        fight_event: {
          event_type: "attack",
          description: "Brick attacks Shing and hits, doing 5 Wounds"
        }
      }

      expect(response).to have_http_status(201)
      body = JSON.parse(response.body)

      expect(body["event_type"]).to eq("attack")
      expect(body["description"]).to eq("Brick attacks Shing and hits, doing 5 Wounds")
      expect(fight.fight_events.count).to eq(1)
    end

    it "returns an error if the event type is missing" do
      post "/api/v1/fights/#{fight.id}/fight_events", headers: headers, params: {
        fight_event: {
          description: "Brick attacks Shing and hits, doing 5 Wounds"
        }
      }

      expect(response).to have_http_status(422)
      body = JSON.parse(response.body)

      expect(body["event_type"]).to include("can't be blank")
    end

    it "returns an error if the description is missing" do
      post "/api/v1/fights/#{fight.id}/fight_events", headers: headers, params: {
        fight_event: {
          event_type: "attack"
        }
      }

      expect(response).to have_http_status(422)
      body = JSON.parse(response.body)

      expect(body["description"]).to include("can't be blank")
    end
  end
end
