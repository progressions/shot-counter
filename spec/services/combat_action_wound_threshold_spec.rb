require "rails_helper"

RSpec.describe CombatActionService, "wound threshold triggering" do
  let!(:user) { User.create!(email: "test@example.com", first_name: "Test", last_name: "User", confirmed_at: Time.now) }
  let!(:campaign) { user.campaigns.create!(name: "Test Campaign") }
  let!(:fight) { campaign.fights.create!(name: "Test Fight") }
  
  describe "automatic Up Check triggering" do
    context "when PC wounds reach threshold" do
      let!(:pc_character) {
        user.characters.create!(
          name: "Hero",
          campaign: campaign,
          action_values: {
            "Type" => "PC",
            "Wounds" => 30,
            "Marks of Death" => 0
          }
        )
      }
      let!(:pc_shot) { fight.shots.create!(character: pc_character, shot: 10) }
      
      it "sets up_check_required status when wounds reach 35" do
        character_updates = [{
          shot_id: pc_shot.id,
          character_id: pc_character.id,
          action_values: { "Wounds" => 35 }
        }]
        
        CombatActionService.apply_combat_action(fight, character_updates)
        
        pc_character.reload
        expect(pc_character.status).to include("up_check_required")
      end
      
      it "increments Marks of Death when threshold is crossed" do
        initial_marks = pc_character.action_values["Marks of Death"]
        
        character_updates = [{
          shot_id: pc_shot.id,
          character_id: pc_character.id,
          action_values: { "Wounds" => 36 }
        }]
        
        CombatActionService.apply_combat_action(fight, character_updates)
        
        pc_character.reload
        expect(pc_character.action_values["Marks of Death"]).to eq(initial_marks + 1)
      end
      
      it "does not trigger if already above threshold" do
        pc_character.update!(action_values: pc_character.action_values.merge("Wounds" => 36))
        
        character_updates = [{
          shot_id: pc_shot.id,
          character_id: pc_character.id,
          action_values: { "Wounds" => 38 }
        }]
        
        CombatActionService.apply_combat_action(fight, character_updates)
        
        pc_character.reload
        expect(pc_character.status).not_to include("up_check_required")
      end
      
      it "clears up_check_required if healed below threshold" do
        pc_character.update!(
          action_values: pc_character.action_values.merge("Wounds" => 36),
          status: ["up_check_required"]
        )
        
        character_updates = [{
          shot_id: pc_shot.id,
          character_id: pc_character.id,
          action_values: { "Wounds" => 30 }
        }]
        
        CombatActionService.apply_combat_action(fight, character_updates)
        
        pc_character.reload
        expect(pc_character.status).not_to include("up_check_required")
      end
    end
    
    context "for different character types" do
      it "does not trigger for Ally characters" do
        ally = user.characters.create!(
          name: "Ally",
          campaign: campaign,
          action_values: {
            "Type" => "Ally",
            "Wounds" => 30,
            "Marks of Death" => 0
          }
        )
        ally_shot = fight.shots.create!(character: ally, shot: 8)
        
        character_updates = [{
          shot_id: ally_shot.id,
          character_id: ally.id,
          action_values: { "Wounds" => 35 }
        }]
        
        CombatActionService.apply_combat_action(fight, character_updates)
        
        ally.reload
        expect(ally.status).not_to include("up_check_required")
      end
      
      it "does not trigger for NPCs" do
        npc = user.characters.create!(
          name: "Villain",
          campaign: campaign,
          action_values: {
            "Type" => "Featured Foe",
            "Wounds" => 30
          }
        )
        npc_shot = fight.shots.create!(character: npc, shot: 5, count: 30)
        
        character_updates = [{
          shot_id: npc_shot.id,
          character_id: npc.id,
          wounds: 35
        }]
        
        CombatActionService.apply_combat_action(fight, character_updates)
        
        npc.reload
        expect(npc.status).not_to include("up_check_required")
      end
      
      it "does not trigger for Mooks" do
        mook = user.characters.create!(
          name: "Mook Squad",
          campaign: campaign,
          action_values: {
            "Type" => "Mook"
          }
        )
        mook_shot = fight.shots.create!(character: mook, shot: 3, count: 5)
        
        character_updates = [{
          shot_id: mook_shot.id,
          character_id: mook.id,
          count: 35
        }]
        
        CombatActionService.apply_combat_action(fight, character_updates)
        
        mook.reload
        expect(mook.status).not_to include("up_check_required")
      end
      
      it "triggers for Boss at 50 wounds" do
        boss = user.characters.create!(
          name: "Big Boss",
          campaign: campaign,
          action_values: {
            "Type" => "Boss",
            "Wounds" => 45,
            "Marks of Death" => 0
          }
        )
        boss_shot = fight.shots.create!(character: boss, shot: 15)
        
        character_updates = [{
          shot_id: boss_shot.id,
          character_id: boss.id,
          action_values: { "Wounds" => 50 }
        }]
        
        # Bosses are NPCs so they shouldn't get up_check_required
        CombatActionService.apply_combat_action(fight, character_updates)
        
        boss.reload
        expect(boss.status).not_to include("up_check_required")
      end
    end
    
    context "multiple Up Checks in same fight" do
      let!(:pc_character) {
        user.characters.create!(
          name: "Tough Hero",
          campaign: campaign,
          action_values: {
            "Type" => "PC",
            "Wounds" => 30,
            "Marks of Death" => 0
          }
        )
      }
      let!(:pc_shot) { fight.shots.create!(character: pc_character, shot: 10) }
      
      it "can trigger multiple times if PC heals and gets wounded again" do
        # First time crossing threshold
        character_updates = [{
          shot_id: pc_shot.id,
          character_id: pc_character.id,
          action_values: { "Wounds" => 35 }
        }]
        
        CombatActionService.apply_combat_action(fight, character_updates)
        pc_character.reload
        expect(pc_character.status).to include("up_check_required")
        expect(pc_character.action_values["Marks of Death"]).to eq(1)
        
        # Clear the up_check_required (simulating successful check)
        pc_character.remove_status("up_check_required")
        
        # Heal below threshold
        character_updates = [{
          shot_id: pc_shot.id,
          character_id: pc_character.id,
          action_values: { "Wounds" => 30 }
        }]
        
        CombatActionService.apply_combat_action(fight, character_updates)
        pc_character.reload
        expect(pc_character.status).not_to include("up_check_required")
        
        # Second time crossing threshold (from 30 back to 36)
        character_updates = [{
          shot_id: pc_shot.id,
          character_id: pc_character.id,
          action_values: { "Wounds" => 36 }
        }]
        
        CombatActionService.apply_combat_action(fight, character_updates)
        pc_character.reload
        expect(pc_character.status).to include("up_check_required")
        expect(pc_character.action_values["Marks of Death"]).to eq(2)
      end
    end
  end
end