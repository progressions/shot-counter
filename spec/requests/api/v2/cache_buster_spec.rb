require 'rails_helper'

RSpec.describe "API V2 Cache Buster", type: :request do
  let(:user) do
    User.create!(
      email: "gamemaster@example.com",
      first_name: "Game",
      last_name: "Master",
      password: "password123",
      gamemaster: true
    )
  end
  
  let(:campaign) do
    Campaign.create!(
      name: "Test Campaign",
      user: user,
      active: true
    )
  end
  
  let(:headers) { authenticated_header(user) }
  
  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow_any_instance_of(ApplicationController).to receive(:current_campaign).and_return(campaign)
  end

  shared_examples "cache buster behavior" do |resource_path, resource_factory_block, resource_name|
    let!(:resource) { instance_exec(&resource_factory_block) if resource_factory_block }
    
    describe "GET #{resource_path}" do
      context "without cache_buster parameter" do
        it "uses cache for the response" do
          # First request to populate cache
          get "/api/v2/#{resource_path}", headers: headers
          expect(response).to have_http_status(:success)
          
          # Expect Rails.cache.fetch to be called (indicating cache usage)
          expect(Rails.cache).to receive(:fetch).and_call_original
          
          # Second request should use cache
          get "/api/v2/#{resource_path}", headers: headers
          expect(response).to have_http_status(:success)
        end
      end
      
      context "with cache_buster parameter" do
        it "skips cache and returns fresh data" do
          # First request to populate cache
          get "/api/v2/#{resource_path}", headers: headers
          expect(response).to have_http_status(:success)
          
          # Expect Rails.cache.fetch NOT to be called when cache_buster is present
          expect(Rails.cache).not_to receive(:fetch)
          
          # Request with cache_buster should skip cache
          get "/api/v2/#{resource_path}?cache_buster=true", headers: headers
          expect(response).to have_http_status(:success)
        end
        
        it "clears related cache entries" do
          # Populate cache
          get "/api/v2/#{resource_path}", headers: headers
          expect(response).to have_http_status(:success)
          
          # Build expected cache key pattern
          identifier = resource_name == "campaigns" ? user.id : campaign.id
          cache_pattern = "#{resource_name}/index/#{identifier}/*"
          
          # Expect cache clearing
          expect(Rails.cache).to receive(:delete_matched).with(cache_pattern).and_call_original
          
          # Request with cache_buster should clear cache
          get "/api/v2/#{resource_path}?cache_buster=true", headers: headers
          expect(response).to have_http_status(:success)
        end
        
        it "returns fresh data after entity creation" do
          # Skip this test if no factory block provided
          unless resource_factory_block
            skip "No resource factory provided for #{resource_name}"
          end
          
          # Get initial count
          get "/api/v2/#{resource_path}", headers: headers
          initial_data = JSON.parse(response.body)
          initial_count = initial_data[resource_name]&.size || 0
          
          # Create new entity
          new_resource = instance_exec(&resource_factory_block)
          
          # Request WITH cache_buster should show new entity
          get "/api/v2/#{resource_path}?cache_buster=true", headers: headers
          fresh_data = JSON.parse(response.body)
          fresh_count = fresh_data[resource_name]&.size || 0
          
          expect(fresh_count).to eq(initial_count + 1)
        end
      end
      
      context "with cache_buster in different formats" do
        %w[true 1 yes TRUE True].each do |truthy_value|
          it "treats '#{truthy_value}' as cache buster" do
            expect(Rails.cache).not_to receive(:fetch)
            
            get "/api/v2/#{resource_path}?cache_buster=#{truthy_value}", headers: headers
            expect(response).to have_http_status(:success)
          end
        end
        
        %w[false 0 no FALSE False].each do |falsy_value|
          it "treats '#{falsy_value}' as normal request (uses cache)" do
            # First request to populate cache
            get "/api/v2/#{resource_path}", headers: headers
            
            expect(Rails.cache).to receive(:fetch).and_call_original
            
            get "/api/v2/#{resource_path}?cache_buster=#{falsy_value}", headers: headers
            expect(response).to have_http_status(:success)
          end
        end
      end
    end
  end
  
  # Test cache buster for all major resources
  describe "Characters" do
    include_examples "cache buster behavior", 
      "characters",
      -> { Character.create!(name: "Test Character", campaign: campaign, action_values: { "Type" => "pc" }) },
      "characters"
  end
  
  describe "Campaigns" do
    include_examples "cache buster behavior", "campaigns", nil, "campaigns"
  end
  
  describe "Vehicles" do
    include_examples "cache buster behavior",
      "vehicles",
      -> { Vehicle.create!(name: "Test Vehicle", campaign: campaign, action_values: {}) },
      "vehicles"
  end
  
  describe "Weapons" do
    include_examples "cache buster behavior",
      "weapons",
      -> { Weapon.create!(name: "Test Weapon", campaign: campaign, damage: 10, concealment: 1, reload_value: 1) },
      "weapons"
  end
  
  describe "Schticks" do
    include_examples "cache buster behavior",
      "schticks",
      -> { Schtick.create!(name: "Test Schtick", campaign: campaign, category: "general") },
      "schticks"
  end
  
  describe "Sites" do
    include_examples "cache buster behavior",
      "sites",
      -> { Site.create!(name: "Test Site", campaign: campaign) },
      "sites"
  end
  
  describe "Parties" do
    include_examples "cache buster behavior",
      "parties",
      -> { Party.create!(name: "Test Party", campaign: campaign) },
      "parties"
  end
  
  describe "Factions" do
    include_examples "cache buster behavior",
      "factions",
      -> { Faction.create!(name: "Test Faction", campaign: campaign) },
      "factions"
  end
  
  describe "Fights" do
    include_examples "cache buster behavior",
      "fights",
      -> { Fight.create!(name: "Test Fight", campaign: campaign, sequence: 0) },
      "fights"
  end
  
  # Test that show actions are NOT affected by cache_buster (they don't use cache)
  describe "Show actions" do
    let(:character) do
      Character.create!(
        name: "Show Test Character",
        campaign: campaign,
        action_values: { "Type" => "pc" }
      )
    end
    
    it "ignores cache_buster parameter on show actions" do
      # Show actions don't use cache, so cache_buster should have no effect
      get "/api/v2/characters/#{character.id}?cache_buster=true", headers: headers
      expect(response).to have_http_status(:success)
      
      data = JSON.parse(response.body)
      expect(data["id"]).to eq(character.id)
    end
  end
  
  # Test interaction with other parameters
  describe "Interaction with other parameters" do
    before do
      5.times do |i|
        Character.create!(
          name: "Character #{i}",
          campaign: campaign,
          action_values: { "Type" => "pc" }
        )
      end
    end
    
    it "works with pagination parameters" do
      get "/api/v2/characters?cache_buster=true&page=1&per_page=2", headers: headers
      expect(response).to have_http_status(:success)
      
      data = JSON.parse(response.body)
      expect(data["characters"].size).to eq(2)
    end
    
    it "works with search parameters" do
      special_character = Character.create!(
        name: "Special Test Character",
        campaign: campaign,
        action_values: { "Type" => "pc" }
      )
      
      get "/api/v2/characters?cache_buster=true&search=Special", headers: headers
      expect(response).to have_http_status(:success)
      
      data = JSON.parse(response.body)
      expect(data["characters"].size).to eq(1)
      expect(data["characters"].first["name"]).to eq("Special Test Character")
    end
    
    it "works with filter parameters" do
      pc_character = Character.create!(
        name: "PC Character",
        campaign: campaign,
        action_values: { "Type" => "pc" }
      )
      npc_character = Character.create!(
        name: "NPC Character",
        campaign: campaign,
        action_values: { "Type" => "npc" }
      )
      
      get "/api/v2/characters?cache_buster=true&character_type=pc", headers: headers
      expect(response).to have_http_status(:success)
      
      data = JSON.parse(response.body)
      pc_names = data["characters"].map { |c| c["name"] }
      expect(pc_names).to include("PC Character")
      expect(pc_names).not_to include("NPC Character")
    end
  end
  
  # Test performance impact
  describe "Performance considerations" do
    it "only clears cache for the specific resource type" do
      # Populate cache for multiple resources
      get "/api/v2/characters", headers: headers
      get "/api/v2/vehicles", headers: headers
      get "/api/v2/weapons", headers: headers
      
      # Expect only characters cache to be cleared
      expect(Rails.cache).to receive(:delete_matched).with("characters/index/#{campaign.id}/*").and_call_original
      expect(Rails.cache).not_to receive(:delete_matched).with("vehicles/index/#{campaign.id}/*")
      expect(Rails.cache).not_to receive(:delete_matched).with("weapons/index/#{campaign.id}/*")
      
      # Cache bust only characters
      get "/api/v2/characters?cache_buster=true", headers: headers
      expect(response).to have_http_status(:success)
    end
  end
  
  # Test authorization still works
  describe "Authorization" do
    let(:other_user) do
      User.create!(
        email: "other@example.com",
        first_name: "Other",
        last_name: "User",
        password: "password123",
        gamemaster: true
      )
    end
    
    let(:other_campaign) do
      Campaign.create!(
        name: "Other Campaign",
        user: other_user,
        active: true
      )
    end
    
    it "respects authorization even with cache_buster" do
      # User shouldn't see campaigns they're not part of
      other_headers = authenticated_header(other_user)
      
      get "/api/v2/campaigns?cache_buster=true", headers: other_headers
      expect(response).to have_http_status(:success)
      
      data = JSON.parse(response.body)
      campaign_ids = data["campaigns"].map { |c| c["id"] }
      expect(campaign_ids).not_to include(campaign.id)
      expect(campaign_ids).to include(other_campaign.id)
    end
  end
  
  # Edge cases
  describe "Edge cases" do
    it "handles cache_buster with empty string" do
      get "/api/v2/characters?cache_buster=", headers: headers
      expect(response).to have_http_status(:success)
    end
    
    it "handles cache_buster with whitespace" do
      get "/api/v2/characters?cache_buster=%20", headers: headers
      expect(response).to have_http_status(:success)
    end
    
    it "handles multiple cache_buster parameters (uses first one)" do
      expect(Rails.cache).not_to receive(:fetch)
      
      get "/api/v2/characters?cache_buster=true&cache_buster=false", headers: headers
      expect(response).to have_http_status(:success)
    end
  end
  
  # Test campaigns controller special case (user-specific cache)
  describe "Campaigns controller special handling" do
    let(:gamemaster) do
      User.create!(
        email: "gm@example.com",
        first_name: "GM",
        last_name: "User",
        password: "password123",
        gamemaster: true
      )
    end
    
    let(:player) do
      User.create!(
        email: "player@example.com",
        first_name: "Player",
        last_name: "User",
        password: "password123",
        gamemaster: false
      )
    end
    
    let!(:gm_campaign) do
      Campaign.create!(
        name: "GM Campaign",
        user: gamemaster,
        active: true
      )
    end
    
    let!(:player_campaign) do
      campaign = Campaign.create!(
        name: "Player Campaign",
        user: gamemaster,
        active: true
      )
      campaign.users << player
      campaign
    end
    
    it "clears user-specific campaign cache for gamemaster" do
      gm_headers = authenticated_header(gamemaster)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(gamemaster)
      
      # Populate cache
      get "/api/v2/campaigns", headers: gm_headers
      
      # Expect user-specific cache pattern
      expect(Rails.cache).to receive(:delete_matched).with("campaigns/index/#{gamemaster.id}/*").and_call_original
      
      get "/api/v2/campaigns?cache_buster=true", headers: gm_headers
      expect(response).to have_http_status(:success)
    end
    
    it "clears user-specific campaign cache for player" do
      player_headers = authenticated_header(player)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(player)
      
      # Populate cache
      get "/api/v2/campaigns", headers: player_headers
      
      # Expect user-specific cache pattern
      expect(Rails.cache).to receive(:delete_matched).with("campaigns/index/#{player.id}/*").and_call_original
      
      get "/api/v2/campaigns?cache_buster=true", headers: player_headers
      expect(response).to have_http_status(:success)
    end
  end
  
  # Include API helper
  include ApiHelper
end