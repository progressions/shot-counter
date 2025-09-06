require "rails_helper"

RSpec.describe ChaseActionService, type: :service do
  before(:each) do
    @user = User.create!(email: "email@example.com", first_name: "Test", last_name: "User")
    @campaign = @user.campaigns.create!(name: "Action Movie")
    @fight = @campaign.fights.create!(name: "Highway Chase")
    
    # Create vehicles
    @pursuer = Vehicle.create!(name: "Police Car", campaign_id: @campaign.id)
    @evader = Vehicle.create!(name: "Getaway Car", campaign_id: @campaign.id)
    
    # Add vehicles to fight
    @pursuer_shot = @fight.shots.create!(vehicle: @pursuer, shot: 10)
    @evader_shot = @fight.shots.create!(vehicle: @evader, shot: 12)
    
    # Create chase relationship
    @relationship = ChaseRelationship.create!(
      pursuer: @pursuer,
      evader: @evader,
      fight: @fight,
      position: "far"
    )
  end

  describe ".apply_chase_action" do
    context "when applying damage that defeats a vehicle" do
      it "creates a defeat event when vehicle is crashed" do
        # Set vehicle close to defeat threshold
        @evader.action_values["Chase Points"] = 30
        @evader.save!
        
        vehicle_updates = [
          {
            vehicle_id: @evader.id,
            action_values: { "Chase Points" => 10 }, # Will add to existing 30
            action_type: "ram" # This will set was_rammed_or_damaged
          }
        ]
        
        expect {
          ChaseActionService.apply_chase_action(@fight, vehicle_updates)
        }.to change(FightEvent, :count).by(1)
        
        defeat_event = @fight.fight_events.last
        expect(defeat_event.event_type).to eq("chase_defeat")
        expect(defeat_event.description).to include("crashed")
        expect(defeat_event.details["defeat_type"]).to eq("crashed")
        
        # Check that vehicle is marked as damaged
        @evader_shot.reload
        expect(@evader_shot.was_rammed_or_damaged).to be true
        
        # Check that vehicle has correct chase points
        @evader.reload
        expect(@evader.action_values["Chase Points"]).to eq(40)
      end
      
      it "creates a defeat event when vehicle is boxed in" do
        # Set vehicle close to defeat threshold
        @evader.action_values["Chase Points"] = 30
        @evader.save!
        
        vehicle_updates = [
          {
            vehicle_id: @evader.id,
            action_values: { "Chase Points" => 10 }, # Will add to existing 30
            action_type: "evade" # This will NOT set was_rammed_or_damaged
          }
        ]
        
        expect {
          ChaseActionService.apply_chase_action(@fight, vehicle_updates)
        }.to change(FightEvent, :count).by(1)
        
        defeat_event = @fight.fight_events.last
        expect(defeat_event.event_type).to eq("chase_defeat")
        expect(defeat_event.description).to include("boxed in")
        expect(defeat_event.details["defeat_type"]).to eq("boxed_in")
        
        # Check that vehicle is NOT marked as damaged
        @evader_shot.reload
        expect(@evader_shot.was_rammed_or_damaged).to be false
      end
      
      it "does not create defeat event when damage doesn't reach threshold" do
        @evader.action_values["Chase Points"] = 20
        @evader.save!
        
        vehicle_updates = [
          {
            vehicle_id: @evader.id,
            action_values: { "Chase Points" => 10 } # Total will be 30, below 35
          }
        ]
        
        expect {
          ChaseActionService.apply_chase_action(@fight, vehicle_updates)
        }.to change(FightEvent, :count).by(0)
        
        @evader.reload
        expect(@evader.action_values["Chase Points"]).to eq(30)
      end
      
      it "only creates one defeat event even if threshold is exceeded multiple times" do
        # Vehicle already defeated
        @evader.action_values["Chase Points"] = 40
        @evader.save!
        
        vehicle_updates = [
          {
            vehicle_id: @evader.id,
            action_values: { "Chase Points" => 10 } # Already defeated, adding more
          }
        ]
        
        expect {
          ChaseActionService.apply_chase_action(@fight, vehicle_updates)
        }.to change(FightEvent, :count).by(0)
      end
    end
    
    context "when tracking ram/sideswipe/weapon damage" do
      it "sets was_rammed_or_damaged for ram action" do
        vehicle_updates = [
          {
            vehicle_id: @evader.id,
            action_type: "ram"
          }
        ]
        
        ChaseActionService.apply_chase_action(@fight, vehicle_updates)
        
        @evader_shot.reload
        expect(@evader_shot.was_rammed_or_damaged).to be true
      end
      
      it "sets was_rammed_or_damaged for sideswipe action" do
        vehicle_updates = [
          {
            vehicle_id: @evader.id,
            action_type: "sideswipe"
          }
        ]
        
        ChaseActionService.apply_chase_action(@fight, vehicle_updates)
        
        @evader_shot.reload
        expect(@evader_shot.was_rammed_or_damaged).to be true
      end
      
      it "sets was_rammed_or_damaged for weapon action" do
        vehicle_updates = [
          {
            vehicle_id: @evader.id,
            action_type: "weapon"
          }
        ]
        
        ChaseActionService.apply_chase_action(@fight, vehicle_updates)
        
        @evader_shot.reload
        expect(@evader_shot.was_rammed_or_damaged).to be true
      end
      
      it "does not set was_rammed_or_damaged for evade action" do
        vehicle_updates = [
          {
            vehicle_id: @evader.id,
            action_type: "evade"
          }
        ]
        
        ChaseActionService.apply_chase_action(@fight, vehicle_updates)
        
        @evader_shot.reload
        expect(@evader_shot.was_rammed_or_damaged).to be false
      end
    end
    
    context "when accumulating damage" do
      it "adds chase points to existing values" do
        @evader.action_values["Chase Points"] = 10
        @evader.save!
        
        vehicle_updates = [
          {
            vehicle_id: @evader.id,
            action_values: { "Chase Points" => 15 }
          }
        ]
        
        ChaseActionService.apply_chase_action(@fight, vehicle_updates)
        
        @evader.reload
        expect(@evader.action_values["Chase Points"]).to eq(25)
      end
      
      it "adds condition points to existing values" do
        @evader.action_values["Condition Points"] = 5
        @evader.save!
        
        vehicle_updates = [
          {
            vehicle_id: @evader.id,
            action_values: { "Condition Points" => 8 }
          }
        ]
        
        ChaseActionService.apply_chase_action(@fight, vehicle_updates)
        
        @evader.reload
        expect(@evader.action_values["Condition Points"]).to eq(13)
      end
    end
    
    context "with Boss driver" do
      before do
        @boss_driver = Character.create!(
          name: "Boss Driver",
          campaign_id: @campaign.id,
          action_values: { "Type" => "Boss" }
        )
        @boss_driver_shot = @fight.shots.create!(
          character: @boss_driver, 
          shot: 15, 
          driving_id: @evader_shot.id
        )
        @evader_shot.update!(driver_id: @boss_driver_shot.id)
      end
      
      it "uses boss threshold of 50 for defeat detection" do
        @evader.action_values["Chase Points"] = 45
        @evader.save!
        
        vehicle_updates = [
          {
            vehicle_id: @evader.id,
            action_values: { "Chase Points" => 10 }, # Total will be 55
            action_type: "ram"
          }
        ]
        
        expect {
          ChaseActionService.apply_chase_action(@fight, vehicle_updates)
        }.to change(FightEvent, :count).by(1)
        
        defeat_event = @fight.fight_events.last
        expect(defeat_event.event_type).to eq("chase_defeat")
        expect(defeat_event.description).to include("crashed")
      end
    end
    
    context "when spending Fortune points" do
      before do
        # Create a PC driver with Fortune points
        @pc_driver = Character.create!(
          name: "PC Driver",
          campaign_id: @campaign.id,
          action_values: { 
            "Type" => "PC",
            "Fortune" => 6,
            "Driving" => 13
          }
        )
        @pc_driver_shot = @fight.shots.create!(
          character: @pc_driver,
          shot: 15
        )
      end
      
      it "deducts Fortune points from the character when fortune_spent is provided" do
        initial_fortune = @pc_driver.action_values["Fortune"]
        expect(initial_fortune).to eq(6)
        
        vehicle_updates = [
          {
            vehicle_id: @pursuer.id,
            target_vehicle_id: @evader.id,
            character_id: @pc_driver.id,
            shot_cost: 3,
            fortune_spent: 1,
            role: "pursuer",
            position: "near",
            event: {
              type: "chase_action",
              description: "#{@pc_driver.name} narrows gap with #{@evader.name} [Fortune]",
              details: {
                fortune_spent: 1
              }
            }
          }
        ]
        
        ChaseActionService.apply_chase_action(@fight, vehicle_updates)
        
        @pc_driver.reload
        expect(@pc_driver.action_values["Fortune"]).to eq(5)
      end
      
      it "only deducts available Fortune when trying to spend more than available" do
        @pc_driver.action_values["Fortune"] = 2
        @pc_driver.save!
        
        vehicle_updates = [
          {
            vehicle_id: @pursuer.id,
            character_id: @pc_driver.id,
            fortune_spent: 5 # Trying to spend more than available
          }
        ]
        
        ChaseActionService.apply_chase_action(@fight, vehicle_updates)
        
        @pc_driver.reload
        expect(@pc_driver.action_values["Fortune"]).to eq(0)
      end
      
      it "does not change Fortune when fortune_spent is not provided" do
        initial_fortune = @pc_driver.action_values["Fortune"]
        
        vehicle_updates = [
          {
            vehicle_id: @pursuer.id,
            character_id: @pc_driver.id,
            shot_cost: 3
            # No fortune_spent parameter
          }
        ]
        
        ChaseActionService.apply_chase_action(@fight, vehicle_updates)
        
        @pc_driver.reload
        expect(@pc_driver.action_values["Fortune"]).to eq(initial_fortune)
      end
      
      it "does not change Fortune when fortune_spent is 0" do
        initial_fortune = @pc_driver.action_values["Fortune"]
        
        vehicle_updates = [
          {
            vehicle_id: @pursuer.id,
            character_id: @pc_driver.id,
            fortune_spent: 0
          }
        ]
        
        ChaseActionService.apply_chase_action(@fight, vehicle_updates)
        
        @pc_driver.reload
        expect(@pc_driver.action_values["Fortune"]).to eq(initial_fortune)
      end
      
      it "handles missing Fortune action value gracefully" do
        # Character without Fortune in action_values
        @npc_driver = Character.create!(
          name: "NPC Driver",
          campaign_id: @campaign.id,
          action_values: { "Driving" => 10 }
        )
        
        vehicle_updates = [
          {
            vehicle_id: @pursuer.id,
            character_id: @npc_driver.id,
            fortune_spent: 1
          }
        ]
        
        expect {
          ChaseActionService.apply_chase_action(@fight, vehicle_updates)
        }.not_to raise_error
        
        @npc_driver.reload
        # Character without Fortune should not have Fortune deducted (stays nil or becomes 0)
        fortune_value = @npc_driver.action_values["Fortune"]
        expect(fortune_value).to satisfy { |v| v.nil? || v == 0 }
      end
      
      it "creates fight event with Fortune details when Fortune is spent" do
        vehicle_updates = [
          {
            vehicle_id: @pursuer.id,
            character_id: @pc_driver.id,
            fortune_spent: 1,
            event: {
              type: "chase_action",
              description: "Chase action with Fortune",
              details: { fortune_spent: 1 }
            }
          }
        ]
        
        expect {
          ChaseActionService.apply_chase_action(@fight, vehicle_updates)
        }.to change(FightEvent, :count).by(1)
        
        event = @fight.fight_events.last
        expect(event.details["fortune_spent"]).to eq(1)
      end
    end
  end
end