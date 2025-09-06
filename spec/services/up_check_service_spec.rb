require "rails_helper"

RSpec.describe UpCheckService do
  let!(:user) { User.create!(email: "test@example.com", first_name: "Test", last_name: "User", confirmed_at: Time.now) }
  let!(:campaign) { user.campaigns.create!(name: "Test Campaign") }
  let!(:fight) { campaign.fights.create!(name: "Test Fight") }
  let!(:pc_character) { 
    user.characters.create!(
      name: "Hero", 
      campaign: campaign, 
      action_values: { 
        "Type" => "PC", 
        "Wounds" => 36,
        "Toughness" => 2,
        "Fortune" => 3,
        "Marks of Death" => 1
      },
      status: ["up_check_required"]
    ) 
  }
  let!(:pc_shot) { fight.shots.create!(character: pc_character, shot: 10) }

  describe "#apply" do
    context "when the check succeeds" do
      it "removes up_check_required status" do
        service = UpCheckService.new(
          fight: fight,
          character_id: pc_character.id,
          swerve: 3,
          fortune: 0
        )
        
        service.apply
        pc_character.reload
        
        expect(pc_character.status).not_to include("up_check_required")
      end

      it "increments Marks of Death" do
        initial_marks = pc_character.action_values["Marks of Death"]
        
        service = UpCheckService.new(
          fight: fight,
          character_id: pc_character.id,
          swerve: 3,
          fortune: 0
        )
        
        service.apply
        pc_character.reload
        
        expect(pc_character.action_values["Marks of Death"]).to eq(initial_marks + 1)
      end

      it "creates a fight event" do
        service = UpCheckService.new(
          fight: fight,
          character_id: pc_character.id,
          swerve: 3,
          fortune: 0
        )
        
        expect {
          service.apply
        }.to change(fight.fight_events, :count).by(1)
        
        event = fight.fight_events.last
        expect(event.event_type).to eq("up_check")
        expect(event.description).to include("succeeded")
        expect(event.details["passed"]).to be true
      end
    end

    context "when the check fails" do
      it "sets status to out_of_fight" do
        service = UpCheckService.new(
          fight: fight,
          character_id: pc_character.id,
          swerve: 1,  # 1 + 2 (Toughness) = 3, which is < 5
          fortune: 0
        )
        
        service.apply
        pc_character.reload
        
        expect(pc_character.status).to eq(["out_of_fight"])
      end

      it "increments Marks of Death" do
        initial_marks = pc_character.action_values["Marks of Death"]
        
        service = UpCheckService.new(
          fight: fight,
          character_id: pc_character.id,
          swerve: 1,
          fortune: 0
        )
        
        service.apply
        pc_character.reload
        
        expect(pc_character.action_values["Marks of Death"]).to eq(initial_marks + 1)
      end

      it "creates a fight event" do
        service = UpCheckService.new(
          fight: fight,
          character_id: pc_character.id,
          swerve: 1,
          fortune: 0
        )
        
        expect {
          service.apply
        }.to change(fight.fight_events, :count).by(1)
        
        event = fight.fight_events.last
        expect(event.event_type).to eq("up_check")
        expect(event.description).to include("failed")
        expect(event.details["passed"]).to be false
      end
    end

    context "when using a Fortune die" do
      it "deducts a Fortune point" do
        initial_fortune = pc_character.action_values["Fortune"]
        
        service = UpCheckService.new(
          fight: fight,
          character_id: pc_character.id,
          swerve: 2,
          fortune: 2
        )
        
        service.apply
        pc_character.reload
        
        expect(pc_character.action_values["Fortune"]).to eq(initial_fortune - 1)
      end

      it "adds an additional Mark of Death" do
        initial_marks = pc_character.action_values["Marks of Death"]
        
        service = UpCheckService.new(
          fight: fight,
          character_id: pc_character.id,
          swerve: 2,
          fortune: 2
        )
        
        service.apply
        pc_character.reload
        
        # One for the check, one for using Fortune
        expect(pc_character.action_values["Marks of Death"]).to eq(initial_marks + 2)
      end

      it "raises error if insufficient Fortune points" do
        pc_character.action_values["Fortune"] = 0
        pc_character.save!
        
        service = UpCheckService.new(
          fight: fight,
          character_id: pc_character.id,
          swerve: 2,
          fortune: 2
        )
        
        expect {
          service.apply
        }.to raise_error(ActiveRecord::RecordInvalid, /Insufficient Fortune points/)
      end

      it "includes fortune usage in fight event" do
        service = UpCheckService.new(
          fight: fight,
          character_id: pc_character.id,
          swerve: 2,
          fortune: 2
        )
        
        service.apply
        
        event = fight.fight_events.last
        expect(event.details["fortune_used"]).to be true
        expect(event.details["fortune"]).to eq(2)
      end
    end

    context "validations" do
      it "raises error if character doesn't require Up Check" do
        pc_character.update!(status: [])
        
        service = UpCheckService.new(
          fight: fight,
          character_id: pc_character.id,
          swerve: 3,
          fortune: 0
        )
        
        expect {
          service.apply
        }.to raise_error(ArgumentError, /does not require an Up Check/)
      end

      it "raises error if character is not a PC" do
        npc = user.characters.create!(
          name: "NPC", 
          campaign: campaign,
          action_values: { "Type" => "Featured Foe" },
          status: ["up_check_required"]
        )
        fight.shots.create!(character: npc, shot: 5)
        
        service = UpCheckService.new(
          fight: fight,
          character_id: npc.id,
          swerve: 3,
          fortune: 0
        )
        
        expect {
          service.apply
        }.to raise_error(ArgumentError, /Only PCs can make Up Checks/)
      end

      it "raises error if character not in fight" do
        other_character = user.characters.create!(
          name: "Other", 
          campaign: campaign,
          action_values: { "Type" => "PC" },
          status: ["up_check_required"]
        )
        
        service = UpCheckService.new(
          fight: fight,
          character_id: other_character.id,
          swerve: 3,
          fortune: 0
        )
        
        expect {
          service.apply
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "broadcasting" do
      it "broadcasts encounter update after transaction" do
        service = UpCheckService.new(
          fight: fight,
          character_id: pc_character.id,
          swerve: 3,
          fortune: 0
        )
        
        expect(fight).to receive(:broadcast_encounter_update!).at_least(:once)
        service.apply
      end
    end
  end

  describe ".apply_up_check" do
    it "creates instance and calls apply" do
      result = UpCheckService.apply_up_check(
        fight: fight,
        character_id: pc_character.id,
        swerve: 3,
        fortune: 0
      )
      
      expect(result).to eq(fight)
      expect(pc_character.reload.status).not_to include("up_check_required")
    end
  end
end