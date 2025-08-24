require "rails_helper"
RSpec.describe "Api::V2::Schticks::Batch", type: :request do
  before(:each) do
    # players
    @gamemaster = User.create!(email: "gamemaster@example.com", confirmed_at: Time.now, gamemaster: true, first_name: "Game", last_name: "Master")
    @player = User.create!(email: "player@example.com", confirmed_at: Time.now, gamemaster: false, first_name: "Player", last_name: "One")
    @campaign = @gamemaster.campaigns.create!(name: "Adventure")
    # characters
    @bandit = Character.create!(name: "Bandit", action_values: { "Type" => "PC", "Archetype" => "Bandit" }, campaign_id: @campaign.id, is_template: true, user_id: @gamemaster.id)
    @brick = Character.create!(
      name: "Brick Manly",
      action_values: { "Type" => "PC", "Archetype" => "Everyday Hero", "Martial Arts" => 13, "MainAttack" => "Martial Arts" },
      description: { "Appearance" => "He's Brick Manly, son" },
      campaign_id: @campaign.id,
      user_id: @player.id,
    )
    @serena = Character.create!(name: "Serena", action_values: { "Type" => "PC", "Archetype" => "Sorcerer" }, campaign_id: @campaign.id, user_id: @player.id)
    @boss = Character.create!(name: "Ugly Shing", action_values: { "Type" => "Boss" }, campaign_id: @campaign.id, user_id: @gamemaster.id)
    @featured_foe = Character.create!(name: "Amanda Yin", action_values: { "Type" => "Featured Foe" }, campaign_id: @campaign.id, user_id: @gamemaster.id)
    @mook = Character.create!(name: "Thug", action_values: { "Type" => "Mook" }, campaign_id: @campaign.id, user_id: @gamemaster.id)
    @ally = Character.create!(name: "Angie Lo", action_values: { "Type" => "Ally" }, campaign_id: @campaign.id, user_id: @gamemaster.id)
    @dead_guy = Character.create!(name: "Dead Guy", action_values: { "Type" => "PC", "Archetype" => "Everyday Hero" }, campaign_id: @campaign.id, user_id: @gamemaster.id, active: false)
    # schticks
    @fireball = Schtick.create!(name: "Fireball", description: "Throws a fireball", category: "Sorcery", path: "Fire", campaign_id: @campaign.id)
    @blast = Schtick.create!(name: "Blast", description: "A big blast", category: "Sorcery", path: "Force", campaign_id: @campaign.id)
    @punch = Schtick.create!(name: "Punch", description: "Throws a punch", category: "Martial Arts", path: "Path of the Tiger", campaign_id: @campaign.id)
    @kick = Schtick.create!(name: "Kick", description: "A flying kick", category: "Martial Arts", path: "Path of the Tiger", campaign_id: @campaign.id)
    @serena.schticks << @fireball
    @serena.schticks << @blast
    @brick.schticks << @punch
    @brick.schticks << @kick
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end

  describe "POST /batch" do
    it "returns error when ids parameter is missing" do
      post "/api/v2/schticks/batch", headers: @headers
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body).to eq({ "error" => "ids parameter is required" })
    end

    it "returns empty array when ids is explicitly empty" do
      post "/api/v2/schticks/batch", params: { ids: "" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"]).to eq([])
      expect(body["categories"]).to eq([])
      expect(body["meta"]).to eq({
        "current_page" => 1,
        "next_page" => nil,
        "prev_page" => nil,
        "total_pages" => 1,
        "total_count" => 0
      })
    end

    it "filters by comma-separated ids" do
      post "/api/v2/schticks/batch", params: { ids: "#{@fireball.id},#{@punch.id}" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |s| s["name"] }).to eq(["Fireball", "Punch"])
      expect(body["categories"]).to eq([])
      expect(body["meta"]).to include(
        "current_page" => 1,
        "total_pages" => 1,
        "total_count" => 2
      )
    end

    it "returns schtick attributes" do
      post "/api/v2/schticks/batch", params: { ids: @fireball.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].length).to eq(1)
      expect(body["schticks"][0]).to include(
        "name" => "Fireball",
        "description" => "Throws a fireball",
      )
      expect(body["schticks"][0].keys).to eq(["id", "name", "description", "entity_class"])
      expect(body["categories"]).to eq([])
    end

    it "returns an empty array when no schticks exist" do
      CharacterSchtick.delete_all
      Schtick.delete_all
      post "/api/v2/schticks/batch", params: { ids: "#{@fireball.id},#{@punch.id}" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"]).to eq([])
      expect(body["categories"]).to eq([])
      expect(body["meta"]).to eq({
        "current_page" => 1,
        "next_page" => nil,
        "prev_page" => nil,
        "total_pages" => 0,
        "total_count" => 0
      })
    end

    it "paginates results" do
      post "/api/v2/schticks/batch", params: { ids: "#{@fireball.id},#{@blast.id},#{@punch.id},#{@kick.id}", per_page: 2, page: 1 }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].length).to eq(2)
      expect(body["meta"]).to include(
        "current_page" => 1,
        "total_pages" => 2,
        "total_count" => 4
      )
    end
  end
end
