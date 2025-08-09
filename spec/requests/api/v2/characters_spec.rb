require "rails_helper"
RSpec.describe "Api::V2::Characters", type: :request do
  before(:each) do
    @gamemaster = User.create!(email: "gamemaster@example.com", confirmed_at: Time.now, gamemaster: true)
    @player = User.create!(email: "player@example.com", confirmed_at: Time.now, gamemaster: false)
    @campaign = @gamemaster.campaigns.create!(name: "Adventure")
    @dragons = @campaign.factions.create!(name: "The Dragons", description: "A bunch of heroes.")
    @ascended = @campaign.factions.create!(name: "The Ascended", description: "A bunch of villains.")
    @dragons_hq = @campaign.sites.create!(name: "Dragons HQ", description: "The Dragons' headquarters.", faction_id: @dragons.id)
    @ascended_hq = @campaign.sites.create!(name: "Ascended HQ", description: "The Ascended's headquarters.", faction_id: @ascended.id)
    @dragons_party = @campaign.parties.create!(name: "Dragons Party", faction_id: @dragons.id)
    @ascended_party = @campaign.parties.create!(name: "Ascended Party", faction_id: @ascended.id)
    @fight = @campaign.fights.create!(name: "Big Brawl")
    @bandit = Character.create!(name: "Bandit", action_values: { "Type" => "PC", "Archetype" => "Bandit" }, campaign_id: @campaign.id, is_template: true, user_id: @gamemaster.id)
    @brick = Character.create!(
      name: "Brick Manly",
      action_values: { "Type" => "PC", "Archetype" => "Everyday Hero", "Martial Arts" => 13, "MainAttack" => "Martial Arts" },
      description: { "Appearance" => "He's Brick Manly, son" },
      campaign_id: @campaign.id,
      faction_id: @dragons.id,
      user_id: @player.id,
    )
    @serena = Character.create!(name: "Serena", action_values: { "Type" => "PC", "Archetype" => "Sorcerer" }, campaign_id: @campaign.id, faction_id: @dragons.id, user_id: @player.id)
    @boss = Character.create!(name: "Ugly Shing", action_values: { "Type" => "Boss" }, campaign_id: @campaign.id, faction_id: @ascended.id, user_id: @gamemaster.id)
    @featured_foe = Character.create!(name: "Amanda Yin", action_values: { "Type" => "Featured Foe" }, campaign_id: @campaign.id, faction_id: @ascended.id, user_id: @gamemaster.id)
    @mook = Character.create!(name: "Thug", action_values: { "Type" => "Mook" }, campaign_id: @campaign.id, faction_id: @ascended.id, user_id: @gamemaster.id)
    @ally = Character.create!(name: "Angie Lo", action_values: { "Type" => "Ally" }, campaign_id: @campaign.id, faction_id: @dragons.id, user_id: @gamemaster.id)
    @dead_guy = Character.create!(name: "Dead Guy", action_values: { "Type" => "PC", "Archetype" => "Everyday Hero" }, campaign_id: @campaign.id, faction_id: @dragons.id, user_id: @gamemaster.id, active: false)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end

  describe "POST /create" do
    it "creates a new character" do
      post "/api/v2/characters", params: { character: { name: "New Character", action_values: { "Type" => "PC" }, faction_id: @dragons.id } }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("New Character")
      expect(body["faction_id"]).to eq(@dragons.id)
      expect(body["image_url"]).to be_nil
      expect(Character.order("created_at").last.name).to eq("New Character")
    end

    it "returns an error when the character name is missing" do
      post "/api/v2/characters", params: { character: { action_values: { "Type" => "PC" }, faction_id: @dragons.id } }, headers: @headers
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("name" => ["can't be blank"])
    end

    it "attaches an image" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      post "/api/v2/characters", params: { image: file, character: { name: "Character with Image", action_values: { "Type" => "PC" }, faction_id: @dragons.id } }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Character with Image")
      expect(body["image_url"]).not_to be_nil
    end
  end

  describe "PATCH /update" do
    it "updates an existing character" do
      patch "/api/v2/characters/#{@brick.id}", params: { character: { name: "Updated Brick Manly", action_values: { "Type" => "PC", "Archetype" => "Everyday Hero" } } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Brick Manly")
      expect(body["action_values"]["Type"]).to eq("PC")
      expect(body["action_values"]["Archetype"]).to eq("Everyday Hero")
      @brick.reload
      expect(@brick.name).to eq("Updated Brick Manly")
      expect(@brick.action_values["Type"]).to eq("PC")
    end

    it "returns an error when the character name is missing" do
      patch "/api/v2/characters/#{@brick.id}", params: { character: { name: "", action_values: { "Type" => "PC", "Archetype" => "Everyday Hero" } } }, headers: @headers
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to eq({ "name" => ["can't be blank"]})
      @brick.reload
      expect(@brick.name).to eq("Brick Manly")
    end

    it "attaches an image" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      patch "/api/v2/characters/#{@brick.id}", params: { image: file, character: { name: "Updated Brick Manly", action_values: { "Type" => "PC" }, faction_id: @dragons.id } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Brick Manly")
      expect(body["image_url"]).not_to be_nil
    end

    it "updates the faction" do
      patch "/api/v2/characters/#{@brick.id}", params: { character: { faction_id: @ascended.id } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly")
      expect(body["faction_id"]).to eq(@ascended.id)
      @brick.reload
      expect(@brick.name).to eq("Brick Manly")
      expect(@brick.faction_id).to eq(@ascended.id)
    end

  end
end
