require "rails_helper"

RSpec.describe "Api::V2::Advancements", type: :request do
  before(:each) do
    @gamemaster = User.create!(
      email: "gamemaster@example.com",
      confirmed_at: Time.now,
      gamemaster: true,
      first_name: "Game",
      last_name: "Master"
    )
    @player = User.create!(
      email: "player@example.com",
      confirmed_at: Time.now,
      gamemaster: false,
      first_name: "Player",
      last_name: "One"
    )
    @campaign = @gamemaster.campaigns.create!(name: "Adventure")
    @brick = Character.create!(
      name: "Brick Manly",
      action_values: { "Type" => "PC" },
      campaign_id: @campaign.id,
      user_id: @player.id
    )
    @boss = Character.create!(
      name: "Ugly Shing",
      action_values: { "Type" => "Boss" },
      campaign_id: @campaign.id
    )
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end

  describe "GET /api/v2/characters/:character_id/advancements" do
    it "gets all of a character's advancements in descending order" do
      advancement1 = @brick.advancements.create!(description: "Increased Leadership skill to 13")
      sleep 0.01 # Ensure different timestamps
      advancement2 = @brick.advancements.create!(description: "Learned new Schtick")

      get "/api/v2/characters/#{@brick.id}/advancements", headers: @headers

      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body.length).to eq(2)
      expect(body[0]["id"]).to eq(advancement2.id)
      expect(body[1]["id"]).to eq(advancement1.id)
      expect(body[0]["description"]).to eq("Learned new Schtick")
      expect(body[1]["description"]).to eq("Increased Leadership skill to 13")
    end

    it "returns empty array when character has no advancements" do
      get "/api/v2/characters/#{@brick.id}/advancements", headers: @headers

      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body).to eq([])
    end

    it "returns 404 for non-existent character" do
      get "/api/v2/characters/999999/advancements", headers: @headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v2/characters/:character_id/advancements" do
    it "creates an advancement for a character" do
      post "/api/v2/characters/#{@brick.id}/advancements",
        headers: @headers,
        params: {
          advancement: {
            description: "Increase Leadership"
          }
        }

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["description"]).to eq("Increase Leadership")
      expect(body["character_id"]).to eq(@brick.id)
      expect(body.keys).to include("id", "description", "created_at", "updated_at", "character_id")
      expect(@brick.reload.advancements.count).to eq(1)
    end

    it "allows creating advancement with empty description" do
      post "/api/v2/characters/#{@brick.id}/advancements",
        headers: @headers,
        params: {
          advancement: {
            description: ""
          }
        }

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["description"]).to eq("")
      expect(@brick.reload.advancements.count).to eq(1)
    end

    it "returns 404 for non-existent character" do
      post "/api/v2/characters/999999/advancements",
        headers: @headers,
        params: {
          advancement: {
            description: "Test advancement"
          }
        }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/v2/characters/:character_id/advancements/:id" do
    it "gets a specific advancement" do
      advancement = @brick.advancements.create!(description: "Increased Leadership skill to 13")

      get "/api/v2/characters/#{@brick.id}/advancements/#{advancement.id}", headers: @headers

      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["id"]).to eq(advancement.id)
      expect(body["description"]).to eq("Increased Leadership skill to 13")
      expect(body["character_id"]).to eq(@brick.id)
      expect(body.keys).to include("id", "description", "created_at", "updated_at", "character_id")
    end

    it "returns 404 for non-existent advancement" do
      get "/api/v2/characters/#{@brick.id}/advancements/999999", headers: @headers

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for non-existent character" do
      get "/api/v2/characters/999999/advancements/999999", headers: @headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /api/v2/characters/:character_id/advancements/:id" do
    it "updates an advancement" do
      advancement = @brick.advancements.create!(description: "Increased Leadership skill")

      patch "/api/v2/characters/#{@brick.id}/advancements/#{advancement.id}",
        headers: @headers,
        params: {
          advancement: {
            description: "Increase Leadership skill to 13"
          }
        }

      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["description"]).to eq("Increase Leadership skill to 13")
      expect(body["id"]).to eq(advancement.id)
      expect(advancement.reload.description).to eq("Increase Leadership skill to 13")
    end

    it "preserves created_at timestamp when editing" do
      advancement = @brick.advancements.create!(description: "Original description")
      original_created_at = advancement.created_at

      sleep 0.1 # Ensure time passes

      patch "/api/v2/characters/#{@brick.id}/advancements/#{advancement.id}",
        headers: @headers,
        params: {
          advancement: {
            description: "Updated description"
          }
        }

      expect(response).to have_http_status(:success)
      advancement.reload
      expect(advancement.created_at.to_i).to eq(original_created_at.to_i)
      expect(advancement.description).to eq("Updated description")
    end

    it "allows updating description to blank" do
      advancement = @brick.advancements.create!(description: "Increased Leadership skill")

      patch "/api/v2/characters/#{@brick.id}/advancements/#{advancement.id}",
        headers: @headers,
        params: {
          advancement: {
            description: ""
          }
        }

      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["description"]).to eq("")
      expect(advancement.reload.description).to eq("")
    end

    it "returns 404 for non-existent advancement" do
      patch "/api/v2/characters/#{@brick.id}/advancements/999999",
        headers: @headers,
        params: {
          advancement: {
            description: "Updated description"
          }
        }

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for non-existent character" do
      patch "/api/v2/characters/999999/advancements/999999",
        headers: @headers,
        params: {
          advancement: {
            description: "Updated description"
          }
        }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v2/characters/:character_id/advancements/:id" do
    it "destroys an advancement" do
      advancement = @brick.advancements.create!(description: "Increased Leadership skill to 13")

      delete "/api/v2/characters/#{@brick.id}/advancements/#{advancement.id}", headers: @headers

      expect(response).to have_http_status(:no_content)
      expect(@brick.reload.advancements).to be_empty
      expect(Advancement.exists?(advancement.id)).to be_falsey
    end

    it "returns 404 for non-existent advancement" do
      delete "/api/v2/characters/#{@brick.id}/advancements/999999", headers: @headers

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for non-existent character" do
      delete "/api/v2/characters/999999/advancements/999999", headers: @headers

      expect(response).to have_http_status(:not_found)
    end

    it "allows deletion without confirmation" do
      advancement1 = @brick.advancements.create!(description: "First advancement")
      advancement2 = @brick.advancements.create!(description: "Second advancement")

      delete "/api/v2/characters/#{@brick.id}/advancements/#{advancement1.id}", headers: @headers

      expect(response).to have_http_status(:no_content)
      expect(@brick.reload.advancements.count).to eq(1)
      expect(@brick.advancements.first.id).to eq(advancement2.id)
    end
  end

  describe "Authorization" do
    before(:each) do
      @player_headers = Devise::JWT::TestHelpers.auth_headers({}, @player)
      set_current_campaign(@player, @campaign)
    end

    it "allows gamemaster to manage any character's advancements" do
      post "/api/v2/characters/#{@brick.id}/advancements",
        headers: @headers,
        params: { advancement: { description: "GM created" } }

      expect(response).to have_http_status(:created)
    end

    it "allows player to manage their own character's advancements" do
      post "/api/v2/characters/#{@brick.id}/advancements",
        headers: @player_headers,
        params: { advancement: { description: "Player created" } }

      expect(response).to have_http_status(:created)
    end
  end
end
