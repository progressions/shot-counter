require "rails_helper"

RSpec.describe Character, "status management", type: :model do
  let!(:user) { User.create!(email: "test@example.com", first_name: "Test", last_name: "User", confirmed_at: Time.now) }
  let!(:campaign) { user.campaigns.create!(name: "Test Campaign") }
  let!(:pc_character) { user.characters.create!(name: "Hero", campaign: campaign, action_values: { "Type" => "PC", "Marks of Death" => 0 }) }
  let!(:npc_character) { user.characters.create!(name: "Villain", campaign: campaign, action_values: { "Type" => "Featured Foe" }) }
  let!(:mook) { user.characters.create!(name: "Mook", campaign: campaign, action_values: { "Type" => "Mook" }) }

  describe "status field" do
    it "defaults to an empty array" do
      expect(pc_character.status).to eq([])
    end

    it "can store status values" do
      pc_character.update(status: ["up_check_required"])
      expect(pc_character.reload.status).to eq(["up_check_required"])
    end

    it "can store multiple status values" do
      pc_character.update(status: ["up_check_required", "impaired"])
      expect(pc_character.reload.status).to include("up_check_required", "impaired")
    end

    it "validates status is an array" do
      pc_character.status = "not_an_array"
      expect(pc_character).not_to be_valid
      expect(pc_character.errors[:status]).to include("must be an array")
    end
  end

  describe "#up_check_required?" do
    it "returns true when status includes up_check_required" do
      pc_character.update(status: ["up_check_required"])
      expect(pc_character.up_check_required?).to be true
    end

    it "returns false when status does not include up_check_required" do
      pc_character.update(status: [])
      expect(pc_character.up_check_required?).to be false
    end

    it "returns false when status includes other values but not up_check_required" do
      pc_character.update(status: ["out_of_fight"])
      expect(pc_character.up_check_required?).to be false
    end
  end

  describe "#out_of_fight?" do
    it "returns true when status includes out_of_fight" do
      pc_character.update(status: ["out_of_fight"])
      expect(pc_character.out_of_fight?).to be true
    end

    it "returns false when status does not include out_of_fight" do
      pc_character.update(status: [])
      expect(pc_character.out_of_fight?).to be false
    end
  end

  describe "#add_status" do
    it "adds a new status to the array" do
      pc_character.add_status("up_check_required")
      expect(pc_character.reload.status).to eq(["up_check_required"])
    end

    it "does not duplicate existing status" do
      pc_character.update(status: ["up_check_required"])
      pc_character.add_status("up_check_required")
      expect(pc_character.reload.status).to eq(["up_check_required"])
    end

    it "adds to existing statuses" do
      pc_character.update(status: ["impaired"])
      pc_character.add_status("up_check_required")
      expect(pc_character.reload.status).to include("impaired", "up_check_required")
    end
  end

  describe "#remove_status" do
    it "removes a status from the array" do
      pc_character.update(status: ["up_check_required", "impaired"])
      pc_character.remove_status("up_check_required")
      expect(pc_character.reload.status).to eq(["impaired"])
    end

    it "handles removing non-existent status gracefully" do
      pc_character.update(status: ["impaired"])
      pc_character.remove_status("up_check_required")
      expect(pc_character.reload.status).to eq(["impaired"])
    end
  end

  describe "#clear_status" do
    it "clears all statuses" do
      pc_character.update(status: ["up_check_required", "out_of_fight", "impaired"])
      pc_character.clear_status
      expect(pc_character.reload.status).to eq([])
    end
  end

  describe "scopes" do
    before do
      pc_character.update(status: ["up_check_required"])
      npc_character.update(status: ["out_of_fight"])
      mook.update(status: [])
    end

    describe ".requiring_up_check" do
      it "returns characters with up_check_required status" do
        results = Character.requiring_up_check
        expect(results).to include(pc_character)
        expect(results).not_to include(npc_character, mook)
      end
    end

    describe ".out_of_fight" do
      it "returns characters with out_of_fight status" do
        results = Character.out_of_fight
        expect(results).to include(npc_character)
        expect(results).not_to include(pc_character, mook)
      end
    end

    describe ".in_fight" do
      it "returns characters without out_of_fight status" do
        results = Character.in_fight
        expect(results).to include(pc_character, mook)
        expect(results).not_to include(npc_character)
      end
    end
  end

  describe "character type helpers" do
    describe "#pc?" do
      it "returns true for PC characters" do
        expect(pc_character.pc?).to be true
      end

      it "returns false for non-PC characters" do
        expect(npc_character.pc?).to be false
        expect(mook.pc?).to be false
      end
    end
  end

  describe "Marks of Death management" do
    it "increments Marks of Death in action_values" do
      initial_marks = pc_character.action_values["Marks of Death"] || 0
      pc_character.increment_marks_of_death
      expect(pc_character.reload.action_values["Marks of Death"]).to eq(initial_marks + 1)
    end

    it "handles nil Marks of Death value" do
      pc_character.action_values.delete("Marks of Death")
      pc_character.save
      pc_character.increment_marks_of_death
      expect(pc_character.reload.action_values["Marks of Death"]).to eq(1)
    end
  end
end