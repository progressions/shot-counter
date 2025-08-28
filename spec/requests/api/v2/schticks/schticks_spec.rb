require "rails_helper"
RSpec.describe "Api::V2::Schticks", type: :request do
  before(:each) do
    allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)

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
    @kick = Schtick.create!(name: "Kick", description: "A flying kick", category: "Martial Arts", path: "Path of the Tiger", campaign_id: @campaign.id, prerequisite_id: @punch.id)

    @serena.schticks << @fireball
    @serena.schticks << @blast
    @brick.schticks << @punch
    @brick.schticks << @kick

    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end

  describe "POST /create" do
    it "creates a new schtick" do
      post "/api/v2/schticks", params: { schtick: { name: "New Schtick", description: "A new ability", category: "Sorcery", path: "Fire", color: "#FF0000", prerequisite_id: @fireball.id } }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("New Schtick")
      expect(body["description"]).to eq("A new ability")
      expect(body["category"]).to eq("Sorcery")
      expect(body["path"]).to eq("Fire")
      expect(body["color"]).to eq("#FF0000")
      expect(body["image_url"]).to be_nil
      expect(body["prerequisite"]).to eq({ "id" => @fireball.id, "name" => @fireball.name, "image_url" => nil, "category" => @fireball.category, "path" => @fireball.path, "entity_class" => "Schtick" })
      expect(Schtick.order("created_at").last.name).to eq("New Schtick")
    end

    it "creates a new schtick with JSON string" do
      post "/api/v2/schticks", params: { schtick: { name: "Json Schtick", description: "A JSON ability", category: "Martial Arts", path: "Path of the Dragon", color: "#00FF00" }.to_json }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Json Schtick")
      expect(body["description"]).to eq("A JSON ability")
      expect(body["category"]).to eq("Martial Arts")
      expect(body["path"]).to eq("Path of the Dragon")
      expect(body["color"]).to eq("#00FF00")
      expect(Schtick.order("created_at").last.name).to eq("Json Schtick")
    end

    it "returns an error when the schtick name is missing" do
      post "/api/v2/schticks", params: { schtick: { description: "A new ability", category: "Sorcery", path: "Fire" } }, headers: @headers
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("name" => ["can't be blank"])
    end

    it "returns an error for invalid JSON string" do
      post "/api/v2/schticks", params: { schtick: "invalid json" }, headers: @headers
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Invalid schtick data format")
    end

    it "returns an error if prerequisite is not in same category and path" do
      post "/api/v2/schticks", params: { schtick: { name: "Flying Kick", description: "A new ability", category: "Sorcery", path: "Fire", prerequisite_id: @kick.id } }, headers: @headers
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("prerequisite" => ["must be in the same category and path"])
    end

    it "attaches an image" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      post "/api/v2/schticks", params: { image: file, schtick: { name: "Schtick with Image", description: "An ability with image", category: "Sorcery", path: "Fire" } }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Schtick with Image")
      expect(body["image_url"]).not_to be_nil
      expect(Schtick.order("created_at").last.image.attached?).to be_truthy
    end
  end

  describe "PATCH /update" do
    it "updates an existing schtick" do
      patch "/api/v2/schticks/#{@fireball.id}", params: { schtick: { name: "Updated Fireball", description: "Updated fireball ability", category: "Sorcery", path: "Flame" } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Fireball")
      expect(body["description"]).to eq("Updated fireball ability")
      expect(body["category"]).to eq("Sorcery")
      expect(body["path"]).to eq("Flame")
      @fireball.reload
      expect(@fireball.name).to eq("Updated Fireball")
      expect(@fireball.description).to eq("Updated fireball ability")
    end

    it "updates an existing schtick with JSON string" do
      patch "/api/v2/schticks/#{@fireball.id}", params: { schtick: { name: "Json Fireball", description: "JSON updated ability", category: "Sorcery", path: "Flame" }.to_json }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Json Fireball")
      expect(body["description"]).to eq("JSON updated ability")
      expect(body["category"]).to eq("Sorcery")
      expect(body["path"]).to eq("Flame")
      @fireball.reload
      expect(@fireball.name).to eq("Json Fireball")
    end

    it "returns an error when the schtick name is missing" do
      patch "/api/v2/schticks/#{@fireball.id}", params: { schtick: { name: "", description: "Updated ability" } }, headers: @headers
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to eq({ "name" => ["can't be blank"] })
      @fireball.reload
      expect(@fireball.name).to eq("Fireball")
    end

    it "returns an error for invalid JSON string" do
      patch "/api/v2/schticks/#{@fireball.id}", params: { schtick: "invalid json" }, headers: @headers
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Invalid schtick data format")
      @fireball.reload
      expect(@fireball.name).to eq("Fireball")
    end

    it "attaches an image" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      patch "/api/v2/schticks/#{@fireball.id}", params: { image: file, schtick: { name: "Updated Fireball", description: "Updated ability" } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Fireball")
      expect(body["image_url"]).not_to be_nil
      @fireball.reload
      expect(@fireball.image.attached?).to be_truthy
    end

    it "replaces an existing image" do
      image = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      @fireball.image.attach(image)
      expect(@fireball.image.attached?).to be_truthy
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      patch "/api/v2/schticks/#{@fireball.id}", params: { image: file, schtick: { name: "Updated Fireball" } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Fireball")
      expect(body["image_url"]).not_to be_nil
      @fireball.reload
      expect(@fireball.image.attached?).to be_truthy
    end

    context "when updating active status" do
      it "sets active to false" do
        patch "/api/v2/schticks/#{@fireball.id}", params: { schtick: { active: false } }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["active"]).to eq(false)
        @fireball.reload
        expect(@fireball.active).to eq(false)
      end

      it "sets active to true" do
        @blast.update!(active: false)
        patch "/api/v2/schticks/#{@blast.id}", params: { schtick: { active: true } }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["active"]).to eq(true)
        @blast.reload
        expect(@blast.active).to eq(true)
      end
    end
  end

  describe "GET /show" do
    it "retrieves a schtick" do
      get "/api/v2/schticks/#{@fireball.id}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Fireball")
      expect(body["description"]).to eq("Throws a fireball")
      expect(body["category"]).to eq("Sorcery")
      expect(body["path"]).to eq("Fire")
      expect(body["image_url"]).to be_nil
      expect(body.keys).to include("id", "name", "description", "category", "path", "image_url", "created_at", "updated_at")
    end

    it "returns a 404 for a non-existent schtick" do
      get "/api/v2/schticks/999999", headers: @headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end

  describe "DELETE /destroy" do
    it "returns an error if the schtick is known by a character" do
      delete "/api/v2/schticks/#{@fireball.id}", headers: @headers
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["errors"]).to eq({ "characters" => true })
    end

    it "deletes a schtick that nobody knows" do
      @levitate = Schtick.create!(name: "Levitate", description: "Allows levitation", category: "Sorcery", path: "Air", campaign_id: @campaign.id)
      delete "/api/v2/schticks/#{@levitate.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(Schtick.exists?(@levitate.id)).to be_falsey
      expect { @levitate.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "deletes a schtick with force=true" do
      delete "/api/v2/schticks/#{@fireball.id}", params: { force: true }, headers: @headers
      expect(response).to have_http_status(:success)
      expect(Schtick.exists?(@fireball.id)).to be_falsey
      expect { @fireball.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns an error for a non-existent schtick" do
      delete "/api/v2/schticks/999999", headers: @headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end

  describe "POST /batch" do
    it "retrieves multiple schticks by IDs" do
      post "/api/v2/schticks/batch", params: { ids: [@fireball.id, @blast.id].join(",") }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["schticks"].length).to eq(2)
      expect(body["schticks"].map { |s| s["id"] }).to contain_exactly(@fireball.id, @blast.id)
    end
  end

  describe "GET /categories" do
    it "retrieves unique schtick categories" do
      @bandit_schtick = Schtick.create!(name: "Stealth", description: "Sneaky stuff", category: "Bandit", path: "Core", campaign_id: @campaign.id)
      get "/api/v2/schticks/categories", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["general"]).to eq(["Martial Arts", "Sorcery"])
      expect(body["core"]).to eq(["Bandit"])
    end

    it "filters categories by search term" do
      get "/api/v2/schticks/categories", params: { search: "martial" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["general"]).to eq(["Martial Arts"])
      expect(body["core"]).to be_empty
    end
  end

  describe "GET /paths" do
    it "retrieves unique schtick paths" do
      get "/api/v2/schticks/paths", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["paths"]).to contain_exactly("Fire", "Force", "Path of the Tiger")
    end

    it "filters paths by category" do
      get "/api/v2/schticks/paths", params: { category: "Martial Arts" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["paths"]).to contain_exactly("Path of the Tiger")
    end

    it "filters paths by search term" do
      get "/api/v2/schticks/paths", params: { search: "fire" }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["paths"]).to contain_exactly("Fire")
    end
  end

end
