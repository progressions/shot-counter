require 'rails_helper'

RSpec.describe CombatActionService do
  before(:each) do
    # Create users
    @gamemaster = User.create!(
      email: "gm@example.com", 
      password: "password", 
      first_name: "Game", 
      last_name: "Master", 
      confirmed_at: Time.current,
      gamemaster: true
    )
    
    @player = User.create!(
      email: "player@example.com",
      password: "password",
      first_name: "Player",
      last_name: "One",
      confirmed_at: Time.current
    )
    
    # Create campaign and fight
    @campaign = Campaign.create!(name: "Test Campaign", user_id: @gamemaster.id)
    @fight = Fight.create!(name: "Test Fight", campaign: @campaign)
    
    # Disable broadcasts for all tests
    allow_any_instance_of(Fight).to receive(:broadcast_encounter_update!)
  end

  describe 'status updates through character_updates' do
    before do
      @pc_character = Character.create!(
        name: "Test PC",
        campaign: @campaign,
        action_values: { "Type" => "PC", "Wounds" => 10 },
        status: []
      )
      
      @npc_character = Character.create!(
        name: "Test NPC",
        campaign: @campaign,
        action_values: { "Type" => "Featured Foe" },
        status: []
      )
      
      @pc_shot = Shot.create!(fight: @fight, character: @pc_character, shot: 12)
      @npc_shot = Shot.create!(fight: @fight, character: @npc_character, shot: 10, count: 0)
    end

    describe 'add_status field' do
      context 'for PC characters' do
        it 'adds a single status to the character' do
          character_updates = [{
            character_id: @pc_character.id,
            add_status: ["cheesing_it"]
          }]

          CombatActionService.apply_combat_action(@fight, character_updates)
          
          @pc_character.reload
          expect(@pc_character.status).to include("cheesing_it")
        end

        it 'adds multiple statuses to the character' do
          character_updates = [{
            character_id: @pc_character.id,
            add_status: ["cheesing_it", "stunned"]
          }]

          CombatActionService.apply_combat_action(@fight, character_updates)
          
          @pc_character.reload
          expect(@pc_character.status).to include("cheesing_it", "stunned")
        end

        it 'does not duplicate existing statuses' do
          @pc_character.add_status("stunned")
          
          character_updates = [{
            character_id: @pc_character.id,
            add_status: ["stunned", "cheesing_it"]
          }]

          CombatActionService.apply_combat_action(@fight, character_updates)
          
          @pc_character.reload
          expect(@pc_character.status).to eq(["stunned", "cheesing_it"])
          expect(@pc_character.status.count("stunned")).to eq(1)
        end
      end

      context 'for NPC characters' do
        it 'adds a single status to the character' do
          character_updates = [{
            character_id: @npc_character.id,
            add_status: ["cheesing_it"]
          }]

          CombatActionService.apply_combat_action(@fight, character_updates)
          
          @npc_character.reload
          expect(@npc_character.status).to include("cheesing_it")
        end

        it 'adds multiple statuses to the character' do
          character_updates = [{
            character_id: @npc_character.id,
            add_status: ["cheesing_it", "out_of_fight"]
          }]

          CombatActionService.apply_combat_action(@fight, character_updates)
          
          @npc_character.reload
          expect(@npc_character.status).to include("cheesing_it", "out_of_fight")
        end
      end
    end

    describe 'remove_status field' do
      context 'for PC characters' do
        before do
          @pc_character.add_status("cheesing_it")
          @pc_character.add_status("stunned")
          @pc_character.save
        end

        it 'removes a single status from the character' do
          character_updates = [{
            character_id: @pc_character.id,
            remove_status: ["cheesing_it"]
          }]

          CombatActionService.apply_combat_action(@fight, character_updates)
          
          @pc_character.reload
          expect(@pc_character.status).not_to include("cheesing_it")
          expect(@pc_character.status).to include("stunned")
        end

        it 'removes multiple statuses from the character' do
          character_updates = [{
            character_id: @pc_character.id,
            remove_status: ["cheesing_it", "stunned"]
          }]

          CombatActionService.apply_combat_action(@fight, character_updates)
          
          @pc_character.reload
          expect(@pc_character.status).to be_empty
        end

        it 'handles removing non-existent status gracefully' do
          character_updates = [{
            character_id: @pc_character.id,
            remove_status: ["non_existent_status"]
          }]

          expect {
            CombatActionService.apply_combat_action(@fight, character_updates)
          }.not_to raise_error
          
          @pc_character.reload
          expect(@pc_character.status).to include("cheesing_it", "stunned")
        end
      end

      context 'for NPC characters' do
        before do
          @npc_character.add_status("cheesing_it")
          @npc_character.add_status("stunned")
          @npc_character.save
        end

        it 'removes a single status from the character' do          
          character_updates = [{
            character_id: @npc_character.id,
            remove_status: ["cheesing_it"]
          }]

          CombatActionService.apply_combat_action(@fight, character_updates)
          
          @npc_character.reload
          
          expect(@npc_character.status).not_to include("cheesing_it")
          expect(@npc_character.status).to include("stunned")
        end
      end
    end

    describe 'combined add and remove status' do
      it 'can transition from one status to another' do
        @pc_character.add_status("cheesing_it")
        
        character_updates = [{
          character_id: @pc_character.id,
          remove_status: ["cheesing_it"],
          add_status: ["cheesed_it"]
        }]

        CombatActionService.apply_combat_action(@fight, character_updates)
        
        @pc_character.reload
        expect(@pc_character.status).not_to include("cheesing_it")
        expect(@pc_character.status).to include("cheesed_it")
      end

      it 'processes remove before add when both are present' do
        @pc_character.add_status("stunned")
        
        character_updates = [{
          character_id: @pc_character.id,
          remove_status: ["stunned"],
          add_status: ["stunned", "cheesing_it"]
        }]

        CombatActionService.apply_combat_action(@fight, character_updates)
        
        @pc_character.reload
        # stunned should be present because it was re-added after removal
        expect(@pc_character.status).to include("stunned", "cheesing_it")
      end
    end

    describe 'status updates with other combat actions' do
      it 'applies status updates along with shot updates' do
        character_updates = [{
          character_id: @pc_character.id,
          shot: 9,
          add_status: ["cheesing_it"],
          event: {
            type: "escape_attempt",
            description: "#{@pc_character.name} is attempting to escape!"
          }
        }]

        CombatActionService.apply_combat_action(@fight, character_updates)
        
        @pc_character.reload
        @pc_shot.reload
        
        expect(@pc_character.status).to include("cheesing_it")
        expect(@pc_shot.shot).to eq(9)
      end

      it 'applies status updates along with wounds and impairments' do
        character_updates = [{
          character_id: @pc_character.id,
          action_values: { "Wounds" => 15 },
          impairments: 1,
          add_status: ["wounded"],
          event: {
            type: "damage",
            description: "#{@pc_character.name} takes damage"
          }
        }]

        CombatActionService.apply_combat_action(@fight, character_updates)
        
        @pc_character.reload
        
        expect(@pc_character.status).to include("wounded")
        expect(@pc_character.action_values["Wounds"]).to eq(15)
        expect(@pc_character.impairments).to eq(1)
      end
    end

    describe 'fight event logging with status updates' do
      it 'creates fight events when status changes occur' do
        character_updates = [{
          character_id: @pc_character.id,
          add_status: ["cheesing_it"],
          event: {
            type: "escape_attempt",
            description: "#{@pc_character.name} is attempting to escape!",
            details: {
              character_id: @pc_character.id,
              status_added: "cheesing_it"
            }
          }
        }]

        expect {
          CombatActionService.apply_combat_action(@fight, character_updates)
        }.to change { @fight.fight_events.count }.by(1)
        
        event = @fight.fight_events.last
        expect(event.event_type).to eq("escape_attempt")
        expect(event.description).to include("attempting to escape")
        expect(event.details["status_added"]).to eq("cheesing_it")
      end
    end
  end
end