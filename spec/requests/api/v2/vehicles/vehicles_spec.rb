require "rails_helper"
RSpec.describe "Api::V2::Vehicles", type: :request do
  before(:each) do
    # players
    @gamemaster = User.create!(email: "gamemaster@example.com", confirmed_at: Time.now, gamemaster: true)
    @player = User.create!(email: "player@example.com", confirmed_at: Time.now, gamemaster: false, first_name: "Player", last_name: "One")

    @campaign = @gamemaster.campaigns.create!(name: "Adventure")

    # factions
    @dragons = @campaign.factions.create!(name: "The Dragons", description: "A bunch of heroes.")
    @ascended = @campaign.factions.create!(name: "The Ascended", description: "A bunch of villains.")

    # parties
    @dragons_party = @campaign.parties.create!(name: "Dragons Party", faction_id: @dragons.id)
    @ascended_party = @campaign.parties.create!(name: "Ascended Party", faction_id: @ascended.id)

    # junctures
    @modern = @campaign.junctures.create!(name: "Modern", description: "The modern world.")
    @ancient = @campaign.junctures.create!(name: "Ancient", description: "The ancient world.")

    # fight
    @fight = @campaign.fights.create!(name: "Big Brawl")

    # vehicles
    @car = @campaign.vehicles.create!(name: "Car", faction_id: @dragons.id, user_id: @player.id, action_values: { Type: "PC", Archetype: "Car" }, juncture_id: @modern.id)
    @tank = @campaign.vehicles.create!(name: "Tank", faction_id: @ascended.id, user_id: @player.id, action_values: { Type: "Boss", Archetype: "Tank" })
    @bike = @campaign.vehicles.create!(name: "Bike", faction_id: @dragons.id, user_id: @player.id, action_values: { Type: "Mook", Archetype: "Bicycle" }, juncture_id: @ancient.id)
    @plane = @campaign.vehicles.create!(name: "Plane", faction_id: @ascended.id, user_id: @player.id, action_values: { Type: "Ally", Archetype: "Airplane" })
    @van = @campaign.vehicles.create!(name: "Van", faction_id: @ascended.id, user_id: @gamemaster.id, action_values: { Type: "Featured Foe", Archetype: "Van" })
    @dead_vehicle = @campaign.vehicles.create!(name: "Dead Car", faction_id: @dragons.id, user_id: @player.id, action_values: { Type: "PC", Archetype: "Car" }, juncture_id: @modern.id, active: false)

    @headers = Devise::JWT::TestHelpers.auth_headers({}, @gamemaster)
    set_current_campaign(@gamemaster, @campaign)
    Rails.cache.clear
  end

  describe "POST /create" do
    it "creates a new vehicle" do
      post "/api/v2/vehicles", params: { vehicle: { name: "New Vehicle", action_values: { "Type" => "PC" }, faction_id: @dragons.id } }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("New Vehicle")
      expect(body["faction_id"]).to eq(@dragons.id)
      expect(body["image_url"]).to be_nil
      expect(Vehicle.order("created_at").last.name).to eq("New Vehicle")
    end

    it "returns an error when the vehicle name is missing" do
      post "/api/v2/vehicles", params: { vehicle: { action_values: { "Type" => "PC" }, faction_id: @dragons.id } }, headers: @headers
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("name" => ["can't be blank"])
    end

    it "attaches an image" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      post "/api/v2/vehicles", params: { image: file, vehicle: { name: "Vehicle with Image", action_values: { "Type" => "PC" }, faction_id: @dragons.id } }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Vehicle with Image")
      expect(body["image_url"]).not_to be_nil
    end
  end

  describe "PATCH /update" do
    it "updates an existing vehicle" do
      patch "/api/v2/vehicles/#{@car.id}", params: { vehicle: { name: "Updated Car", action_values: { "Type" => "PC", "Archetype" => "Car" } } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Car")
      expect(body["action_values"]["Type"]).to eq("PC")
      expect(body["action_values"]["Archetype"]).to eq("Car")
      @car.reload
      expect(@car.name).to eq("Updated Car")
      expect(@car.action_values["Type"]).to eq("PC")
    end

    it "returns an error when the vehicle name is missing" do
      patch "/api/v2/vehicles/#{@car.id}", params: { vehicle: { name: "", action_values: { "Type" => "PC", "Archetype" => "Everyday Hero" } } }, headers: @headers
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to eq({ "name" => ["can't be blank"]})
      @car.reload
      expect(@car.name).to eq("Car")
    end

    it "attaches an image" do
      file = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      patch "/api/v2/vehicles/#{@car.id}", params: { image: file, vehicle: { name: "Updated Car", action_values: { "Type" => "PC" }, faction_id: @dragons.id } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Updated Car")
      expect(body["image_url"]).not_to be_nil
    end

    it "updates the faction" do
      patch "/api/v2/vehicles/#{@car.id}", params: { vehicle: { faction_id: @ascended.id } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Car")
      expect(body["faction_id"]).to eq(@ascended.id)
      @car.reload
      expect(@car.name).to eq("Car")
      expect(@car.faction_id).to eq(@ascended.id)
    end

    it "updates the juncture" do
      patch "/api/v2/vehicles/#{@car.id}", params: { vehicle: { juncture_id: @ancient.id } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Car")
      expect(body["juncture_id"]).to eq(@ancient.id)
      @car.reload
      expect(@car.name).to eq("Car")
      expect(@car.juncture_id).to eq(@ancient.id)
    end
  end

  describe "GET /show" do
    it "retrieves a vehicle" do
      get "/api/v2/vehicles/#{@car.id}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Car")
      expect(body["action_values"]["Type"]).to eq("PC")
      expect(body["action_values"]["Archetype"]).to eq("Car")
      expect(body["faction_id"]).to eq(@dragons.id)
      expect(body["juncture_id"]).to eq(@modern.id)
      expect(body["user_id"]).to eq(@player.id)
      expect(body["image_url"]).to be_nil
      expect(body.keys).to include("id", "name", "action_values", "description", "faction_id", "user_id", "image_url", "active", "user", "faction", "juncture", "image_positions", "created_at", "updated_at", "entity_class")
      expect(body["user"]).to eq({ "id" => @player.id, "name" => "Player One", "email" => @player.email, "entity_class" => "User" })
      expect(body["faction"]).to eq({ "id" => @dragons.id, "name" => "The Dragons", "entity_class" => "Faction" })
      expect(body["juncture"]).to eq({ "id" => @modern.id, "name" => "Modern", "entity_class" => "Juncture" })
    end

    it "returns a 404 for a non-existent vehicle" do
      get "/api/v2/vehicles/999999", headers: @headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end

  describe "DELETE /destroy" do
    it "deletes a vehicle" do
      delete "/api/v2/vehicles/#{@car.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(Vehicle.exists?(@car.id)).to be_falsey
      expect { @car.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  xdescribe "POST /duplicate" do
    # come back to this in the future
    it "duplicates a vehicle" do
      post "/api/v2/vehicles/#{@car.id}/duplicate", headers: @headers
      expect(response).to have_http_status(:created)
      expect(Vehicle.count).to eq(9) # 8 original + 1 duplicate
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Car (1)")
      expect(body["action_values"]["Type"]).to eq("PC")
      expect(body["action_values"]["Archetype"]).to eq("Everyday Hero")
      expect(body["faction_id"]).to eq(@dragons.id)
      expect(body["user_id"]).to eq(@gamemaster.id)
      expect(body["image_url"]).to be_nil
    end

    it "duplicates a vehicle again" do
      post "/api/v2/vehicles/#{@car.id}/duplicate", headers: @headers
      post "/api/v2/vehicles/#{@car.id}/duplicate", headers: @headers
      expect(response).to have_http_status(:created)
      expect(Vehicle.count).to eq(10)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Car (2)")
      expect(body["action_values"]["Type"]).to eq("PC")
      expect(body["action_values"]["Archetype"]).to eq("Everyday Hero")
      expect(body["faction_id"]).to eq(@dragons.id)
      expect(body["user_id"]).to eq(@gamemaster.id)
      expect(body["image_url"]).to be_nil
    end

    it "duplicates a vehicle with an image" do
      @car.image.attach(io: File.open("spec/fixtures/files/image.jpg"), filename: "image.jpg", content_type: "image/jpg")
      post "/api/v2/vehicles/#{@car.id}/duplicate", headers: @headers
      expect(response).to have_http_status(:created)
      expect(Vehicle.count).to eq(9) # 8 original + 1 duplicate
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Car (1)")
      expect(body["image_url"]).not_to be_nil
    end
  end

  xdescribe "POST /pdf" do
    # come back to this in the future
    it "uploads a pdf" do
      file = fixture_file_upload("spec/fixtures/files/Archer.pdf", "application/pdf")
      post "/api/v2/vehicles/pdf", params: { pdf_file: file }, headers: @headers
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Archer")
      expect(body["action_values"]["Type"]).to eq("PC")
      expect(body["action_values"]["Archetype"]).to eq("Archer")
      expect(body["action_values"]["MainAttack"]).to eq("Guns")
      expect(body["action_values"]["Guns"]).to eq(14)
      expect(body["action_values"]["Defense"]).to eq(14)
      expect(body["action_values"]["Toughness"]).to eq(6)
      expect(body["action_values"]["Speed"]).to eq(8)
      expect(body["action_values"]["FortuneType"]).to eq("Chi")
      expect(body["action_values"]["Fortune"]).to eq(7)
      expect(body["action_values"]["Max Fortune"]).to eq(7)
    end

    it "returns an error for an invalid pdf" do
      file = fixture_file_upload("spec/fixtures/files/invalid.pdf", "application/pdf")
      post "/api/v2/vehicles/pdf", params: { pdf_file: file }, headers: @headers
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Failed to import vehicle: Invalid PDF: Missing required fields")
    end
  end

  describe "DELETE /remove_image" do
    it "removes an image from a vehicle" do
      allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
      image = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      @car.image.attach(image)
      expect(@car.image.attached?).to be_truthy
      delete "/api/v2/vehicles/#{@car.id}/image", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["image_url"]).to be_nil
      @car.reload
      expect(@car.image.attached?).to be_falsey
      expect(@car.image_url).to be_nil
    end
  end

end
