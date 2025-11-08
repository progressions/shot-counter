require "rails_helper"
RSpec.describe "Api::V2::Characters", type: :request do
  before(:each) do
    # players
    @gamemaster = User.create!(email: "gamemaster@example.com", first_name: "Game", last_name: "Master", confirmed_at: Time.now, gamemaster: true)
    @player = User.create!(email: "player@example.com", confirmed_at: Time.now, gamemaster: false, first_name: "Player", last_name: "One")

    @campaign = @gamemaster.campaigns.create!(name: "Adventure")

    # factions
    @dragons = @campaign.factions.create!(name: "The Dragons", description: "A bunch of heroes.")
    @ascended = @campaign.factions.create!(name: "The Ascended", description: "A bunch of villains.")

    # sites
    @dragons_hq = @campaign.sites.create!(name: "Dragons HQ", description: "The Dragons' headquarters.", faction_id: @dragons.id)
    @ascended_hq = @campaign.sites.create!(name: "Ascended HQ", description: "The Ascended's headquarters.", faction_id: @ascended.id)

    # parties
    @dragons_party = @campaign.parties.create!(name: "Dragons Party", faction_id: @dragons.id)
    @ascended_party = @campaign.parties.create!(name: "Ascended Party", faction_id: @ascended.id)

    # junctures
    @modern = @campaign.junctures.create!(name: "Modern", description: "The modern world.")
    @ancient = @campaign.junctures.create!(name: "Ancient", description: "The ancient world.")

    # weapons
    @sword = @campaign.weapons.create!(name: "Sword", description: "A sharp blade.", damage: 10, juncture: "Ancient", category: "Melee")
    @gun = @campaign.weapons.create!(name: "Gun", description: "A ranged weapon.", damage: 15, juncture: "Modern", category: "Ranged")

    # fight
    @fight = @campaign.fights.create!(name: "Big Brawl")

    # characters
    @bandit = Character.create!(name: "Bandit", action_values: { "Type" => "PC", "Archetype" => "Bandit" }, campaign_id: @campaign.id, is_template: true, user_id: @gamemaster.id)
    @brick = Character.create!(
      name: "Brick Manly",
      action_values: { "Type" => "PC", "Archetype" => "Everyday Hero", "Martial Arts" => 13, "MainAttack" => "Martial Arts" },
      description: { "Appearance" => "He's Brick Manly, son" },
      campaign_id: @campaign.id,
      faction_id: @dragons.id,
      juncture_id: @modern.id,
      user_id: @player.id,
    )
    @serena = Character.create!(name: "Serena", action_values: { "Type" => "PC", "Archetype" => "Sorcerer" }, campaign_id: @campaign.id, faction_id: @dragons.id, user_id: @player.id, juncture_id: @ancient.id)
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
      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("name" => ["can't be blank"])
    end

    it "attaches an image", skip: "Image processing disabled in test environment" do
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
      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body["errors"]).to eq({ "name" => ["can't be blank"]})
      @brick.reload
      expect(@brick.name).to eq("Brick Manly")
    end

    it "attaches an image", skip: "Image processing disabled in test environment" do
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

    it "updates the juncture" do
      patch "/api/v2/characters/#{@brick.id}", params: { character: { juncture_id: @ancient.id } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly")
      expect(body["juncture_id"]).to eq(@ancient.id)
      @brick.reload
      expect(@brick.name).to eq("Brick Manly")
      expect(@brick.juncture_id).to eq(@ancient.id)
    end

    it "updates the wealth" do
      patch "/api/v2/characters/#{@brick.id}", params: { character: { wealth: "Rich" } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly")
      expect(body["wealth"]).to eq("Rich")
      @brick.reload
      expect(@brick.name).to eq("Brick Manly")
      expect(@brick.wealth).to eq("Rich")
    end

    it "updates the skills" do
      skills_data = { "Detective" => 12, "Driving" => 10 }
      patch "/api/v2/characters/#{@brick.id}", params: { character: { skills: skills_data } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly")
      expect(body["skills"]).to include("Detective" => 12, "Driving" => 10)
      @brick.reload
      expect(@brick.name).to eq("Brick Manly")
      expect(@brick.skills["Detective"]).to eq(12)
      expect(@brick.skills["Driving"]).to eq(10)
    end

    it "adds a schtick" do
      schtick = @campaign.schticks.create!(name: "Super Strength", description: "Gives super strength.", category: "Everyday Hero", path: "Core")
      patch "/api/v2/characters/#{@brick.id}", params: { character: { schtick_ids: [schtick.id] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly")
      expect(body["schtick_ids"]).to include(schtick.id)
      @brick.reload
      expect(@brick.schticks).to include(schtick)
    end

    it "removes a schtick" do
      schtick = @campaign.schticks.create!(name: "Super Strength", description: "Gives super strength.", category: "Everyday Hero", path: "Core")
      schtick2 = @campaign.schticks.create!(name: "Super Speed", description: "Gives super speed.", category: "Everyday Hero", path: "Core")
      @brick.schticks << schtick
      @brick.schticks << schtick2
      patch "/api/v2/characters/#{@brick.id}", params: { character: { schtick_ids: [schtick.id] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly")
      expect(body["schtick_ids"]).to include(schtick.id)
      expect(body["schtick_ids"]).not_to include(schtick2.id)
      @brick.reload
      expect(@brick.schticks).to include(schtick)
      expect(@brick.schticks).not_to include(schtick2)
    end

    it "adds a weapon" do
      weapon = @campaign.weapons.create!(name: "Laser Gun", description: "A futuristic weapon.", damage: 20, juncture: "Modern", category: "Ranged")
      patch "/api/v2/characters/#{@brick.id}", params: { character: { weapon_ids: [weapon.id] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly")
      expect(body["weapon_ids"]).to include(weapon.id)
      @brick.reload
      expect(@brick.weapons).to include(weapon)
    end

    it "removes a weapon" do
      weapon = @campaign.weapons.create!(name: "Laser Gun", description: "A futuristic weapon.", damage: 20, juncture: "Modern", category: "Ranged")
      weapon2 = @campaign.weapons.create!(name: "Plasma Rifle", description: "A powerful rifle.", damage: 25, juncture: "Modern", category: "Ranged")
      @brick.weapons << weapon
      @brick.weapons << weapon2
      patch "/api/v2/characters/#{@brick.id}", params: { character: { weapon_ids: [weapon.id] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly")
      expect(body["weapon_ids"]).to include(weapon.id)
      expect(body["weapon_ids"]).not_to include(weapon2.id)
      @brick.reload
      expect(@brick.weapons).to include(weapon)
      expect(@brick.weapons).not_to include(weapon2)
    end

    it "adds a site" do
      site = @campaign.sites.create!(name: "New Site", description: "A new site for testing.", faction_id: @dragons.id)
      patch "/api/v2/characters/#{@brick.id}", params: { character: { site_ids: [site.id] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly")
      expect(body["site_ids"]).to include(site.id)
      @brick.reload
      expect(@brick.sites).to include(site)
    end

    it "removes a site" do
      site = @campaign.sites.create!(name: "New Site", description: "A new site for testing.", faction_id: @dragons.id)
      site2 = @campaign.sites.create!(name: "Another Site", description: "Another site for testing.", faction_id: @dragons.id)
      @brick.sites << site
      @brick.sites << site2
      patch "/api/v2/characters/#{@brick.id}", params: { character: { site_ids: [site.id] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly")
      expect(body["site_ids"]).to include(site.id)
      expect(body["site_ids"]).not_to include(site2.id)
      @brick.reload
      expect(@brick.sites).to include(site)
      expect(@brick.sites).not_to include(site2)
    end

    it "adds a party" do
      party = @campaign.parties.create!(name: "New Party", description: "A new party for testing.", faction_id: @dragons.id)
      patch "/api/v2/characters/#{@brick.id}", params: { character: { party_ids: [party.id] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly")
      expect(body["party_ids"]).to include(party.id)
      @brick.reload
      expect(@brick.parties).to include(party)
    end

    it "removes a party" do
      party = @campaign.parties.create!(name: "New Party", description: "A new party for testing.", faction_id: @dragons.id)
      party2 = @campaign.parties.create!(name: "Another Party", description: "Another party for testing.", faction_id: @dragons.id)
      @brick.parties << party
      @brick.parties << party2
      patch "/api/v2/characters/#{@brick.id}", params: { character: { party_ids: [party.id] } }, headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly")
      expect(body["party_ids"]).to include(party.id)
      expect(body["party_ids"]).not_to include(party2.id)
      @brick.reload
      expect(@brick.parties).to include(party)
      expect(@brick.parties).not_to include(party2)
    end

    context "wounds and impairments" do
      it "updates wounds for a PC using action_values" do
        patch "/api/v2/characters/#{@brick.id}", params: { 
          character: { 
            action_values: { "Wounds" => 5, "Marks of Death" => 2 } 
          } 
        }, headers: @headers
        
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["action_values"]["Wounds"]).to eq(5)
        expect(body["action_values"]["Marks of Death"]).to eq(2)
        
        @brick.reload
        expect(@brick.action_values["Wounds"]).to eq(5)
        expect(@brick.action_values["Marks of Death"]).to eq(2)
      end

      it "updates impairments for a PC" do
        patch "/api/v2/characters/#{@brick.id}", params: { 
          character: { impairments: 3 } 
        }, headers: @headers
        
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["impairments"]).to eq(3)
        
        @brick.reload
        expect(@brick.impairments).to eq(3)
      end

      it "updates marks of death for non-PCs" do
        patch "/api/v2/characters/#{@featured_foe.id}", params: { 
          character: { 
            action_values: { "Marks of Death" => 3 }
          } 
        }, headers: @headers
        
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["action_values"]["Marks of Death"]).to eq(3)
        
        @featured_foe.reload
        expect(@featured_foe.action_values["Marks of Death"]).to eq(3)
      end

      it "preserves existing action_values when updating marks of death" do
        @boss.update!(
          action_values: { 
            "Type" => "Boss", 
            "MainAttack" => "Guns",
            "Guns" => 15,
            "Defense" => 14
          }
        )
        
        patch "/api/v2/characters/#{@boss.id}", params: { 
          character: { 
            action_values: { "Marks of Death" => 1 }
          } 
        }, headers: @headers
        
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["action_values"]["Type"]).to eq("Boss")
        expect(body["action_values"]["MainAttack"]).to eq("Guns")
        expect(body["action_values"]["Guns"]).to eq(15)
        expect(body["action_values"]["Defense"]).to eq(14)
        expect(body["action_values"]["Marks of Death"]).to eq(1)
        
        @boss.reload
        expect(@boss.action_values["Marks of Death"]).to eq(1)
        expect(@boss.action_values["Type"]).to eq("Boss")
      end

      # Note: count and impairments for non-PCs are handled through the Shot association
      # when the character is in a fight. See spec/requests/api/v2/shots_spec.rb
    end

    context "ownership reassignment" do
      before(:each) do
        @new_owner = User.create!(email: "newowner@example.com", confirmed_at: Time.now, first_name: "New", last_name: "Owner")
        @campaign.users << @new_owner
        @non_member = User.create!(email: "nonmember@example.com", confirmed_at: Time.now, first_name: "Non", last_name: "Member")
      end

      context "as gamemaster" do
        it "allows reassigning character ownership to another campaign member" do
          patch "/api/v2/characters/#{@brick.id}", 
            params: { character: { user_id: @new_owner.id } }, 
            headers: @headers
          
          expect(response).to have_http_status(:success)
          body = JSON.parse(response.body)
          expect(body["user"]["id"]).to eq(@new_owner.id)
          
          @brick.reload
          expect(@brick.user_id).to eq(@new_owner.id)
        end

        it "prevents reassigning ownership to non-campaign member" do
          patch "/api/v2/characters/#{@brick.id}", 
            params: { character: { user_id: @non_member.id } }, 
            headers: @headers
          
          expect(response).to have_http_status(:unprocessable_content)
          body = JSON.parse(response.body)
          expect(body["errors"]["user_id"]).to include("must be a member of the campaign")
          
          @brick.reload
          expect(@brick.user_id).to eq(@player.id)
        end
      end

      context "as regular player" do
        before(:each) do
          @player_headers = Devise::JWT::TestHelpers.auth_headers({}, @player)
          set_current_campaign(@player, @campaign)
        end

        it "prevents reassigning character ownership" do
          patch "/api/v2/characters/#{@brick.id}", 
            params: { character: { user_id: @new_owner.id } }, 
            headers: @player_headers
          
          expect(response).to have_http_status(:forbidden)
          body = JSON.parse(response.body)
          expect(body["error"]).to eq("Not authorized to reassign character ownership")
          
          @brick.reload
          expect(@brick.user_id).to eq(@player.id)
        end
      end

      context "as admin" do
        before(:each) do
          @admin = User.create!(email: "admin@example.com", confirmed_at: Time.now, admin: true, first_name: "Admin", last_name: "User")
          @admin_headers = Devise::JWT::TestHelpers.auth_headers({}, @admin)
          set_current_campaign(@admin, @campaign)
        end

        it "allows reassigning character ownership" do
          patch "/api/v2/characters/#{@brick.id}", 
            params: { character: { user_id: @new_owner.id } }, 
            headers: @admin_headers
          
          expect(response).to have_http_status(:success)
          body = JSON.parse(response.body)
          expect(body["user"]["id"]).to eq(@new_owner.id)
          
          @brick.reload
          expect(@brick.user_id).to eq(@new_owner.id)
        end
      end
    end

    context "when updating active status" do
      it "sets active to false" do
        patch "/api/v2/characters/#{@brick.id}", params: { character: { active: false } }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["active"]).to eq(false)
        @brick.reload
        expect(@brick.active).to eq(false)
      end

      it "sets active to true" do
        @dead_guy.update!(active: false)
        patch "/api/v2/characters/#{@dead_guy.id}", params: { character: { active: true } }, headers: @headers
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["active"]).to eq(true)
        @dead_guy.reload
        expect(@dead_guy.active).to eq(true)
      end
    end
  end

  describe "GET /show" do
    it "retrieves a character" do
      @brick.weapons << @sword
      @brick.weapons << @gun

      get "/api/v2/characters/#{@brick.id}", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly")
      expect(body["action_values"]["Type"]).to eq("PC")
      expect(body["action_values"]["Archetype"]).to eq("Everyday Hero")
      expect(body["faction_id"]).to eq(@dragons.id)
      expect(body["user_id"]).to eq(@player.id)
      expect(body["image_url"]).to be_nil
      expect(body.keys).to include("id", "name", "action_values", "description", "faction_id", "user_id", "image_url", "active", "user", "faction", "juncture", "image_positions", "created_at", "updated_at", "entity_class")
      expect(body["user"]).to eq({ "id" => @player.id, "name" => "Player One", "email" => @player.email, "entity_class" => "User" })
      expect(body["faction"]).to eq({ "id" => @dragons.id, "name" => "The Dragons", "entity_class" => "Faction" })
      expect(body["juncture"]).to eq({ "id" => @modern.id, "name" => "Modern", "entity_class" => "Juncture" })
      expect(body["weapon_ids"].sort).to eq([@sword.id, @gun.id].sort)
    end

    it "returns a 404 for a non-existent character" do
      get "/api/v2/characters/999999", headers: @headers
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Record not found")
    end
  end

  describe "DELETE /destroy" do
    it "deletes a character" do
      delete "/api/v2/characters/#{@brick.id}", headers: @headers
      expect(response).to have_http_status(:success)
      expect(Character.exists?(@brick.id)).to be_falsey
      expect { @brick.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "POST /duplicate" do
    it "duplicates a character" do
      @brick.weapons << @sword
      @brick.weapons << @gun
      post "/api/v2/characters/#{@brick.id}/duplicate", headers: @headers
      expect(response).to have_http_status(:created)
      expect(Character.count).to eq(9) # 8 original + 1 duplicate
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly (1)")
      expect(body["action_values"]["Type"]).to eq("PC")
      expect(body["action_values"]["Archetype"]).to eq("Everyday Hero")
      expect(body["faction_id"]).to eq(@dragons.id)
      expect(body["user_id"]).to eq(@gamemaster.id)
      expect(body["image_url"]).to be_nil
      expect(body["weapon_ids"].sort).to eq([@sword.id, @gun.id].sort)
    end

    it "duplicates a character again" do
      @brick.weapons << @sword
      @brick.weapons << @gun
      post "/api/v2/characters/#{@brick.id}/duplicate", headers: @headers
      post "/api/v2/characters/#{@brick.id}/duplicate", headers: @headers
      expect(response).to have_http_status(:created)
      expect(Character.count).to eq(10)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly (2)")
      expect(body["action_values"]["Type"]).to eq("PC")
      expect(body["action_values"]["Archetype"]).to eq("Everyday Hero")
      expect(body["faction_id"]).to eq(@dragons.id)
      expect(body["user_id"]).to eq(@gamemaster.id)
      expect(body["image_url"]).to be_nil
      expect(body["weapon_ids"].sort).to eq([@sword.id, @gun.id].sort)
    end

    it "duplicates a character with an image", skip: "Image processing disabled in test environment" do
      @brick.image.attach(io: File.open("spec/fixtures/files/image.jpg"), filename: "image.jpg", content_type: "image/jpg")
      post "/api/v2/characters/#{@brick.id}/duplicate", headers: @headers
      expect(response).to have_http_status(:created)
      expect(Character.count).to eq(9) # 8 original + 1 duplicate
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly (1)")
      expect(body["image_url"]).not_to be_nil
    end
  end

  describe "POST /pdf" do
    it "uploads a pdf", skip: "PDF processing disabled in test environment" do
      file = fixture_file_upload("spec/fixtures/files/Archer.pdf", "application/pdf")
      post "/api/v2/characters/pdf", params: { pdf_file: file }, headers: @headers
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

    it "returns an error for an invalid pdf", skip: "PDF processing disabled in test environment" do
      file = fixture_file_upload("spec/fixtures/files/invalid.pdf", "application/pdf")
      post "/api/v2/characters/pdf", params: { pdf_file: file }, headers: @headers
      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Failed to import character: Invalid PDF: Missing required fields")
    end
  end

  describe "POST /sync" do
    it "syncs character from Notion successfully" do
      # Mock the NotionService.update_character_from_notion to return true
      allow(NotionService).to receive(:update_character_from_notion).with(@brick).and_return(true)
      
      post "/api/v2/characters/#{@brick.id}/sync", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Brick Manly")
      expect(body["id"]).to eq(@brick.id)
    end

    it "returns error when Notion sync fails" do
      # Mock the NotionService.update_character_from_notion to return false
      allow(NotionService).to receive(:update_character_from_notion).with(@brick).and_return(false)
      
      post "/api/v2/characters/#{@brick.id}/sync", headers: @headers
      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Notion sync failed")
    end

    it "returns a 404 for a non-existent character" do
      post "/api/v2/characters/999999/sync", headers: @headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /pdf" do
    it "generates and sends a PDF for a character" do
      # Mock the PdfService.character_to_pdf to return a temp file path
      temp_path = "/tmp/test_character.pdf"
      allow(PdfService).to receive(:character_to_pdf).with(@brick).and_return(temp_path)
      
      # Mock send_file since we can't test actual file sending in request specs
      allow_any_instance_of(Api::V2::CharactersController).to receive(:send_file).with(
        temp_path, 
        type: "application/pdf", 
        disposition: "attachment", 
        filename: "brick_manly_character_sheet.pdf"
      ).and_return(true)
      
      get "/api/v2/characters/#{@brick.id}/pdf", headers: @headers
      expect(response).to have_http_status(:success)
    end

    it "returns a 404 for a non-existent character" do
      get "/api/v2/characters/999999/pdf", headers: @headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /remove_image" do
    it "removes an image from a character", skip: "Image processing disabled in test environment" do
      allow_any_instance_of(ActiveStorage::Blob).to receive(:purge).and_return(true)
      image = fixture_file_upload("spec/fixtures/files/image.jpg", "image/jpg")
      @brick.image.attach(image)
      expect(@brick.image.attached?).to be_truthy
      delete "/api/v2/characters/#{@brick.id}/image", headers: @headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["image_url"]).to be_nil
      @brick.reload
      expect(@brick.image.attached?).to be_falsey
      expect(@brick.image_url).to be_nil
    end
  end

end
