require "rails_helper"

RSpec.describe Vehicle, type: :model do
  before(:each) do
    @user = User.create!(email: "email@example.com", first_name: "Test", last_name: "User")
    @action_movie = @user.campaigns.create!(name: "Action Movie")
    @rogues = @action_movie.factions.create!(name: "Rogues")
  end

  it "sets default action values" do
    truck = Vehicle.create!(name: "Truck", campaign_id: @action_movie.id)
    expect(truck.action_values).to eq(Vehicle::DEFAULT_ACTION_VALUES)
  end

  it "sets integer values if you try to save strings" do
    truck = Vehicle.create!(name: "Truck", campaign_id: @action_movie.id)
    truck.action_values["Acceleration"] = "8"
    truck.save!
    expect(truck.action_values["Acceleration"]).to eq(8)
  end

  describe "associations" do
    it "belongs to a campaign" do
      truck = Vehicle.create!(name: "Truck", campaign_id: @action_movie.id)
      expect(truck.campaign).to eq(@action_movie)
    end

    it "has many action values" do
      truck = Vehicle.create!(name: "Truck", campaign_id: @action_movie.id)
      expect(truck.action_values).to be_a(Hash)
    end

    it "has many fights" do
      truck = Vehicle.create!(name: "Truck", campaign_id: @action_movie.id)
      fight = @action_movie.fights.create!(name: "Big Brawl")
      fight.vehicles << truck
      expect(truck.fights).to include(fight)
    end

    it "has many vehicle_effects" do
      truck = Vehicle.create!(name: "Truck", campaign_id: @action_movie.id)
      fight = @action_movie.fights.create!(name: "Big Brawl")
      fight.vehicles << truck
      shot = fight.shots.create!(vehicle: truck, shot: 10)
      effect = shot.character_effects.create!(name: "Injured", vehicle: truck)
      expect(truck.character_effects).to include(effect)
    end

    it "has many parties" do
      truck = Vehicle.create!(name: "Truck", campaign_id: @action_movie.id)
      party = @action_movie.parties.create!(name: "The Dragons")
      party.vehicles << truck
      expect(truck.parties).to include(party)
    end

    it "has a faction" do
      truck = Vehicle.create!(name: "Truck", campaign_id: @action_movie.id, faction_id: @rogues.id)
      expect(truck.faction).to eq(@rogues)
    end
  end

  describe "validations" do
    it "requires a name" do
      truck = Vehicle.new(campaign_id: @action_movie.id)
      expect(truck).to_not be_valid
      expect(truck.errors[:name]).to include("can't be blank")
    end

    it "requires a campaign" do
      truck = Vehicle.new(name: "Truck")
      expect(truck).to_not be_valid
      expect(truck.errors[:campaign]).to include("must exist")
    end

    it "doesn't require a user" do
      truck = Vehicle.new(name: "Truck", campaign_id: @action_movie.id)
      expect(truck).to be_valid
      expect(truck.errors[:user]).to be_empty
    end
  end

  describe "driver" do
    it "includes driver in JSON" do
      truck = Vehicle.create!(name: "Truck", campaign_id: @action_movie.id)
      fight = @action_movie.fights.create!(name: "Big Brawl")
      truck_shot = fight.shots.create!(vehicle: truck, shot: 10)

      driver = Character.create!(name: "Driver", campaign_id: @action_movie.id)
      driver.skills["Driving"] = 13
      driver.save!

      driver_shot = fight.shots.create(character: driver, shot: 15, driving_id: truck_shot.id)
      truck_shot.driver_id = driver_shot.id

      json = truck.as_v1_json(shot: truck_shot)
      expect(json[:driver][:name]).to eq(driver.name)
      expect(json[:driver][:id]).to eq(driver.id)
      expect(json[:driver][:skills]).to eq({"Driving" => 13})
    end
  end

  describe "defeat detection" do
    before(:each) do
      @vehicle = Vehicle.create!(name: "Test Car", campaign_id: @action_movie.id)
      @fight = @action_movie.fights.create!(name: "Chase Scene")
      @shot = @fight.shots.create!(vehicle: @vehicle, shot: 10)
    end

    describe "#defeated_in_chase?" do
      context "with Featured Foe driver" do
        before do
          @driver = Character.create!(
            name: "Driver", 
            campaign_id: @action_movie.id,
            action_values: { "Type" => "Featured Foe" }
          )
          @driver_shot = @fight.shots.create!(character: @driver, shot: 15, driving_id: @shot.id)
          @shot.update!(driver_id: @driver_shot.id)
        end

        it "returns false when chase points are below threshold" do
          @vehicle.action_values["Chase Points"] = 34
          @vehicle.save!
          expect(@vehicle.defeated_in_chase?(@shot)).to be false
        end

        it "returns true when chase points reach threshold" do
          @vehicle.action_values["Chase Points"] = 35
          @vehicle.save!
          expect(@vehicle.defeated_in_chase?(@shot)).to be true
        end

        it "returns true when chase points exceed threshold" do
          @vehicle.action_values["Chase Points"] = 40
          @vehicle.save!
          expect(@vehicle.defeated_in_chase?(@shot)).to be true
        end
      end

      context "with Boss driver" do
        before do
          @driver = Character.create!(
            name: "Boss Driver", 
            campaign_id: @action_movie.id,
            action_values: { "Type" => "Boss" }
          )
          @driver_shot = @fight.shots.create!(character: @driver, shot: 15, driving_id: @shot.id)
          @shot.update!(driver_id: @driver_shot.id)
        end

        it "returns false when chase points are below boss threshold" do
          @vehicle.action_values["Chase Points"] = 49
          @vehicle.save!
          expect(@vehicle.defeated_in_chase?(@shot)).to be false
        end

        it "returns true when chase points reach boss threshold" do
          @vehicle.action_values["Chase Points"] = 50
          @vehicle.save!
          expect(@vehicle.defeated_in_chase?(@shot)).to be true
        end
      end

      context "with no driver" do
        it "uses vehicle type for threshold" do
          @vehicle.action_values["Type"] = "Featured Foe"
          @vehicle.action_values["Chase Points"] = 35
          @vehicle.save!
          expect(@vehicle.defeated_in_chase?(@shot)).to be true
        end
      end
    end

    describe "#defeat_threshold" do
      it "returns 35 for Featured Foe driver" do
        driver = Character.create!(
          name: "Driver",
          campaign_id: @action_movie.id,
          action_values: { "Type" => "Featured Foe" }
        )
        driver_shot = @fight.shots.create!(character: driver, shot: 15, driving_id: @shot.id)
        @shot.update!(driver_id: driver_shot.id)
        
        expect(@vehicle.defeat_threshold(@shot)).to eq(35)
      end

      it "returns 50 for Boss driver" do
        driver = Character.create!(
          name: "Boss Driver",
          campaign_id: @action_movie.id,
          action_values: { "Type" => "Boss" }
        )
        driver_shot = @fight.shots.create!(character: driver, shot: 15, driving_id: @shot.id)
        @shot.update!(driver_id: driver_shot.id)
        
        expect(@vehicle.defeat_threshold(@shot)).to eq(50)
      end

      it "returns 50 for Uber-Boss driver" do
        driver = Character.create!(
          name: "Uber-Boss Driver",
          campaign_id: @action_movie.id,
          action_values: { "Type" => "Uber-Boss" }
        )
        driver_shot = @fight.shots.create!(character: driver, shot: 15, driving_id: @shot.id)
        @shot.update!(driver_id: driver_shot.id)
        
        expect(@vehicle.defeat_threshold(@shot)).to eq(50)
      end

      it "returns 35 for PC driver" do
        driver = Character.create!(
          name: "Player Driver",
          campaign_id: @action_movie.id,
          action_values: { "Type" => "PC" }
        )
        driver_shot = @fight.shots.create!(character: driver, shot: 15, driving_id: @shot.id)
        @shot.update!(driver_id: driver_shot.id)
        
        expect(@vehicle.defeat_threshold(@shot)).to eq(35)
      end
    end

    describe "#defeat_type" do
      before do
        @vehicle.action_values["Chase Points"] = 35
        @vehicle.save!
      end

      it "returns nil when not defeated" do
        @vehicle.action_values["Chase Points"] = 30
        @vehicle.save!
        expect(@vehicle.defeat_type(@shot)).to be_nil
      end

      it "returns 'crashed' when defeated and was_rammed_or_damaged is true" do
        @shot.update!(was_rammed_or_damaged: true)
        expect(@vehicle.defeat_type(@shot)).to eq("crashed")
      end

      it "returns 'boxed_in' when defeated and was_rammed_or_damaged is false" do
        @shot.update!(was_rammed_or_damaged: false)
        expect(@vehicle.defeat_type(@shot)).to eq("boxed_in")
      end
    end

    describe "JSON serialization with defeat info" do
      it "includes defeat-related fields in as_v1_json" do
        @vehicle.action_values["Chase Points"] = 40
        @vehicle.save!
        @shot.update!(was_rammed_or_damaged: true)

        json = @vehicle.as_v1_json(shot: @shot)
        
        expect(json[:was_rammed_or_damaged]).to be true
        expect(json[:is_defeated_in_chase]).to be true
        expect(json[:defeat_type]).to eq("crashed")
        expect(json[:defeat_threshold]).to eq(35)
      end
    end
  end
end
