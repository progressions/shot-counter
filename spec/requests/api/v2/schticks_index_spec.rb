require "rails_helper"

RSpec.describe "Api::V2::Schticks", type: :request do
  before(:each) do
    # players
    @gamemaster = User.create!(email: "gamemaster@example.com", confirmed_at: Time.now, gamemaster: true)
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

  describe "GET /index" do
    it "gets all schticks" do
      get "/api/v2/schticks", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |c| c["name"] }).to eq(["Kick", "Punch", "Blast", "Fireball"])
    end

    it "returns schtick attributes" do
      get "/api/v2/schticks", params: { search: "Fireball" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].length).to eq(1)
      expect(body["schticks"][0]).to include("name" => "Fireball", "entity_class" => "Schtick")
      expect(body["schticks"][0].keys).to eq(["id", "name", "image_url", "description", "category", "path", "created_at", "updated_at", "entity_class", "prerequisite_id", "image_positions"])
    end

    it "returns an empty array when no schticks exist" do
      CharacterSchtick.delete_all
      Schtick.delete_all
      get "/api/v2/schticks", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"]).to eq([])
    end

    it "returns all categories, not just the current page" do
      get "/api/v2/schticks", params: { per_page: 2, page: 1, sort: "category" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["categories"]).to eq(["Sorcery", "Martial Arts"])
    end

    it "sorts by created_at ascending" do
      get "/api/v2/schticks", params: { sort: "created_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |s| s["name"] }).to eq(["Fireball", "Blast", "Punch", "Kick"])
      expect(body["categories"]).to eq(["Sorcery", "Martial Arts"])
      expect(body["paths"]).to eq(["Fire", "Force", "Path of the Tiger"])
    end

    it "sorts by created_at descending" do
      get "/api/v2/schticks", params: { sort: "created_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |s| s["name"] }).to eq(["Kick", "Punch", "Blast", "Fireball"])
      expect(body["categories"]).to eq(["Martial Arts", "Sorcery"])
      expect(body["paths"]).to eq(["Path of the Tiger", "Force", "Fire"])
    end

    it "sorts by updated_at ascending" do
      @punch.touch
      get "/api/v2/schticks", params: { sort: "updated_at", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |s| s["name"] }).to eq(["Fireball", "Blast", "Kick", "Punch"])
      expect(body["categories"]).to eq(["Sorcery", "Martial Arts"])
      expect(body["paths"]).to eq(["Fire", "Force", "Path of the Tiger"])
    end

    it "sorts by updated_at descending" do
      @punch.touch
      get "/api/v2/schticks", params: { sort: "updated_at", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |s| s["name"] }).to eq(["Punch", "Kick", "Blast", "Fireball"])
      expect(body["categories"]).to eq(["Martial Arts", "Sorcery"])
      expect(body["paths"]).to eq(["Path of the Tiger", "Force", "Fire"])
    end

    it "sorts by name ascending" do
      get "/api/v2/schticks", params: { sort: "name", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |s| s["name"] }).to eq(["Blast", "Fireball", "Kick", "Punch"])
      expect(body["categories"]).to eq(["Sorcery", "Martial Arts"])
      expect(body["paths"]).to eq(["Force", "Fire", "Path of the Tiger"])
    end

    it "sorts by name descending" do
      get "/api/v2/schticks", params: { sort: "name", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |s| s["name"] }).to eq(["Punch", "Kick", "Fireball", "Blast"])
      expect(body["categories"]).to eq(["Martial Arts", "Sorcery"])
      expect(body["paths"]).to eq(["Path of the Tiger", "Fire", "Force"])
    end

    it "sorts by category ascending" do
      get "/api/v2/schticks", params: { sort: "category", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |s| s["name"] }).to eq(["Kick", "Punch", "Blast", "Fireball"])
      expect(body["categories"]).to eq(["Martial Arts", "Sorcery"])
      expect(body["paths"]).to eq(["Path of the Tiger", "Force", "Fire"])
    end

    it "sorts by category descending" do
      get "/api/v2/schticks", params: { sort: "category", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |s| s["name"] }).to eq(["Fireball", "Blast", "Punch", "Kick"])
      expect(body["categories"]).to eq(["Sorcery", "Martial Arts"])
      expect(body["paths"]).to eq(["Fire", "Force", "Path of the Tiger"])
    end

    it "sorts by path ascending" do
      get "/api/v2/schticks", params: { sort: "path", order: "asc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |s| s["name"] }).to eq(["Fireball", "Blast", "Kick", "Punch"])
      expect(body["categories"]).to eq(["Sorcery", "Martial Arts"])
      expect(body["paths"]).to eq(["Fire", "Force", "Path of the Tiger"])
    end

    it "sorts by path descending" do
      get "/api/v2/schticks", params: { sort: "path", order: "desc" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |s| s["name"] }).to eq(["Punch", "Kick", "Blast", "Fireball"])
      expect(body["categories"]).to eq(["Martial Arts", "Sorcery"])
      expect(body["paths"]).to eq(["Path of the Tiger", "Force", "Fire"])
    end

    it "filters by id" do
      get "/api/v2/schticks", params: { id: @fireball.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |s| s["name"] }).to eq(["Fireball"])
      expect(body["categories"]).to eq(["Sorcery"])
      expect(body["paths"]).to eq(["Fire"])
    end

    it "filters by character_id" do
      get "/api/v2/schticks", params: { character_id: @serena.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |s| s["name"] }).to eq(["Blast", "Fireball"])
      expect(body["categories"]).to eq(["Sorcery"])
      expect(body["paths"]).to eq(["Force", "Fire"])
    end

    it "filters by character_id" do
      get "/api/v2/schticks", params: { character_id: @brick.id }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |s| s["name"] }).to eq(["Kick", "Punch"])
      expect(body["categories"]).to eq(["Martial Arts"])
      expect(body["paths"]).to eq(["Path of the Tiger"])
    end

    it "filters by category" do
      get "/api/v2/schticks", params: { category: "Sorcery" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |s| s["name"] }).to eq(["Blast", "Fireball"])
      expect(body["categories"]).to eq(["Sorcery"])
      expect(body["paths"]).to eq(["Force", "Fire"])
    end

    it "filters by category" do
      get "/api/v2/schticks", params: { category: "Martial Arts" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |s| s["name"] }).to eq(["Kick", "Punch"])
      expect(body["categories"]).to eq(["Martial Arts"])
      expect(body["paths"]).to eq(["Path of the Tiger"])
    end

    it "filters by path" do
      get "/api/v2/schticks", params: { path: "Fire" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |s| s["name"] }).to eq(["Fireball"])
      expect(body["categories"]).to eq(["Sorcery"])
      expect(body["paths"]).to eq(["Fire"])
    end

    it "filters by path" do
      get "/api/v2/schticks", params: { path: "Path of the Tiger" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |s| s["name"] }).to eq(["Kick", "Punch"])
      expect(body["categories"]).to eq(["Martial Arts"])
      expect(body["paths"]).to eq(["Path of the Tiger"])
    end

    it "filters by search string" do
      get "/api/v2/schticks", params: { search: "Fire" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |s| s["name"] }).to eq(["Fireball"])
      expect(body["categories"]).to eq(["Sorcery"])
      expect(body["paths"]).to eq(["Fire"])
    end

    it "filters by search string" do
      get "/api/v2/schticks", params: { search: "Punch" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].map { |s| s["name"] }).to eq(["Punch"])
      expect(body["categories"]).to eq(["Martial Arts"])
      expect(body["paths"]).to eq(["Path of the Tiger"])
    end

    describe "GET /autocomplete" do
      it "sorts by created_at ascending" do
        get "/api/v2/schticks", params: { autocomplete: true, sort: "created_at", order: "asc" }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["schticks"].map { |s| s["name"] }).to eq(["Fireball", "Blast", "Punch", "Kick"])
        expect(body["categories"]).to eq(["Sorcery", "Martial Arts"])
        expect(body["paths"]).to eq(["Fire", "Force", "Path of the Tiger"])
      end

      it "sorts by created_at descending" do
        get "/api/v2/schticks", params: { autocomplete: true, sort: "created_at", order: "desc" }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["schticks"].map { |s| s["name"] }).to eq(["Kick", "Punch", "Blast", "Fireball"])
        expect(body["categories"]).to eq(["Martial Arts", "Sorcery"])
        expect(body["paths"]).to eq(["Path of the Tiger", "Force", "Fire"])
      end

      it "sorts by updated_at ascending" do
        @punch.touch
        get "/api/v2/schticks", params: { autocomplete: true, sort: "updated_at", order: "asc" }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["schticks"].map { |s| s["name"] }).to eq(["Fireball", "Blast", "Kick", "Punch"])
        expect(body["categories"]).to eq(["Sorcery", "Martial Arts"])
        expect(body["paths"]).to eq(["Fire", "Force", "Path of the Tiger"])
      end

      it "sorts by updated_at descending" do
        @punch.touch
        get "/api/v2/schticks", params: { autocomplete: true, sort: "updated_at", order: "desc" }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["schticks"].map { |s| s["name"] }).to eq(["Punch", "Kick", "Blast", "Fireball"])
        expect(body["categories"]).to eq(["Martial Arts", "Sorcery"])
        expect(body["paths"]).to eq(["Path of the Tiger", "Force", "Fire"])
      end

      it "sorts by name ascending" do
        get "/api/v2/schticks", params: { autocomplete: true, sort: "name", order: "asc" }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["schticks"].map { |s| s["name"] }).to eq(["Blast", "Fireball", "Kick", "Punch"])
        expect(body["categories"]).to eq(["Sorcery", "Martial Arts"])
        expect(body["paths"]).to eq(["Force", "Fire", "Path of the Tiger"])
      end

      it "sorts by name descending" do
        get "/api/v2/schticks", params: { autocomplete: true, sort: "name", order: "desc" }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["schticks"].map { |s| s["name"] }).to eq(["Punch", "Kick", "Fireball", "Blast"])
        expect(body["categories"]).to eq(["Martial Arts", "Sorcery"])
        expect(body["paths"]).to eq(["Path of the Tiger", "Fire", "Force"])
      end

      it "sorts by category ascending" do
        get "/api/v2/schticks", params: { autocomplete: true, sort: "category", order: "asc" }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["schticks"].map { |s| s["name"] }).to eq(["Kick", "Punch", "Blast", "Fireball"])
        expect(body["categories"]).to eq(["Martial Arts", "Sorcery"])
        expect(body["paths"]).to eq(["Path of the Tiger", "Force", "Fire"])
      end

      it "sorts by category descending" do
        get "/api/v2/schticks", params: { autocomplete: true, sort: "category", order: "desc" }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["schticks"].map { |s| s["name"] }).to eq(["Fireball", "Blast", "Punch", "Kick"])
        expect(body["categories"]).to eq(["Sorcery", "Martial Arts"])
        expect(body["paths"]).to eq(["Fire", "Force", "Path of the Tiger"])
      end

      it "sorts by path ascending" do
        get "/api/v2/schticks", params: { autocomplete: true, sort: "path", order: "asc" }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["schticks"].map { |s| s["name"] }).to eq(["Fireball", "Blast", "Kick", "Punch"])
        expect(body["categories"]).to eq(["Sorcery", "Martial Arts"])
        expect(body["paths"]).to eq(["Fire", "Force", "Path of the Tiger"])
      end

      it "sorts by path descending" do
        get "/api/v2/schticks", params: { autocomplete: true, sort: "path", order: "desc" }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["schticks"].map { |s| s["name"] }).to eq(["Punch", "Kick", "Blast", "Fireball"])
        expect(body["categories"]).to eq(["Martial Arts", "Sorcery"])
        expect(body["paths"]).to eq(["Path of the Tiger", "Force", "Fire"])
      end

      it "filters by character_id" do
        get "/api/v2/schticks", params: { autocomplete: true, character_id: @serena.id }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["schticks"].map { |s| s["name"] }).to eq(["Blast", "Fireball"])
        expect(body["categories"]).to eq(["Sorcery"])
        expect(body["paths"]).to eq(["Force", "Fire"])
      end

      it "filters by character_id" do
        get "/api/v2/schticks", params: { autocomplete: true, character_id: @brick.id }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["schticks"].map { |s| s["name"] }).to eq(["Kick", "Punch"])
        expect(body["categories"]).to eq(["Martial Arts"])
        expect(body["paths"]).to eq(["Path of the Tiger"])
      end

      it "filters by category" do
        get "/api/v2/schticks", params: { autocomplete: true, category: "Sorcery" }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["schticks"].map { |s| s["name"] }).to eq(["Blast", "Fireball"])
        expect(body["categories"]).to eq(["Sorcery"])
        expect(body["paths"]).to eq(["Force", "Fire"])
      end

      it "filters by category" do
        get "/api/v2/schticks", params: { autocomplete: true, category: "Martial Arts" }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["schticks"].map { |s| s["name"] }).to eq(["Kick", "Punch"])
        expect(body["categories"]).to eq(["Martial Arts"])
        expect(body["paths"]).to eq(["Path of the Tiger"])
      end

      it "filters by path" do
        get "/api/v2/schticks", params: { autocomplete: true, path: "Fire" }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["schticks"].map { |s| s["name"] }).to eq(["Fireball"])
        expect(body["categories"]).to eq(["Sorcery"])
        expect(body["paths"]).to eq(["Fire"])
      end

      it "filters by path" do
        get "/api/v2/schticks", params: { autocomplete: true, path: "Path of the Tiger" }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["schticks"].map { |s| s["name"] }).to eq(["Kick", "Punch"])
        expect(body["categories"]).to eq(["Martial Arts"])
        expect(body["paths"]).to eq(["Path of the Tiger"])
      end

      it "filters by search string" do
        get "/api/v2/schticks", params: { autocomplete: true, search: "Fire" }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["schticks"].map { |s| s["name"] }).to eq(["Fireball"])
        expect(body["categories"]).to eq(["Sorcery"])
        expect(body["paths"]).to eq(["Fire"])
      end

      it "filters by search string" do
        get "/api/v2/schticks", params: { autocomplete: true, search: "Punch" }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["schticks"].map { |s| s["name"] }).to eq(["Punch"])
        expect(body["categories"]).to eq(["Martial Arts"])
        expect(body["paths"]).to eq(["Path of the Tiger"])
      end
    end
  end
end
