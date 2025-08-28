require 'rails_helper'

RSpec.describe CampaignDeletionService do
  let(:user) { User.create!(email: "test@example.com", first_name: "Test", last_name: "User", gamemaster: true, confirmed_at: Time.now) }
  let(:campaign) { Campaign.create!(name: "Test Campaign", user: user) }
  let(:service) { described_class.new }
  
  describe '#association_counts' do
    it 'returns counts for all campaign associations' do
      # Create associated records
      3.times { |i| Character.create!(name: "Character #{i}", campaign: campaign, action_values: {}) }
      2.times { |i| Vehicle.create!(name: "Vehicle #{i}", campaign: campaign, action_values: {}) }
      Fight.create!(name: "Fight", campaign: campaign, sequence: 1)
      Site.create!(name: "Site", campaign: campaign)
      Party.create!(name: "Party", campaign: campaign)
      Faction.create!(name: "Faction", campaign: campaign)
      Juncture.create!(name: "Contemporary", campaign: campaign)
      
      counts = service.send(:association_counts, campaign)
      
      expect(counts['characters'][:count]).to eq(3)
      expect(counts['characters'][:label]).to eq('characters')
      expect(counts['vehicles'][:count]).to eq(2)
      expect(counts['vehicles'][:label]).to eq('vehicles')
      expect(counts['fights'][:count]).to eq(1)
      expect(counts['fights'][:label]).to eq('active fights')
      expect(counts['sites'][:count]).to eq(1)
      expect(counts['sites'][:label]).to eq('sites')
      expect(counts['parties'][:count]).to eq(1)
      expect(counts['parties'][:label]).to eq('parties')
      expect(counts['factions'][:count]).to eq(1)
      expect(counts['factions'][:label]).to eq('factions')
      expect(counts['junctures'][:count]).to eq(1)
      expect(counts['junctures'][:label]).to eq('junctures')
    end
    
    it 'returns zero counts when no associations exist' do
      counts = service.send(:association_counts, campaign)
      
      expect(counts['characters'][:count]).to eq(0)
      expect(counts['vehicles'][:count]).to eq(0)
      expect(counts['fights'][:count]).to eq(0)
    end
  end
  
  describe '#handle_associations' do
    it 'deletes all associated records' do
      character = Character.create!(name: "Character", campaign: campaign, action_values: {})
      vehicle = Vehicle.create!(name: "Vehicle", campaign: campaign, action_values: {})
      fight = Fight.create!(name: "Fight", campaign: campaign, sequence: 1)
      site = Site.create!(name: "Site", campaign: campaign)
      party = Party.create!(name: "Party", campaign: campaign)
      faction = Faction.create!(name: "Faction", campaign: campaign)
      juncture = Juncture.create!(name: "Contemporary", campaign: campaign)
      
      service.send(:handle_associations, campaign)
      
      # All records should be deleted
      expect { character.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { vehicle.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { fight.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { site.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { juncture.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { party.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { faction.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
    
    it 'handles faction references correctly' do
      faction1 = Faction.create!(name: "The Dragons", campaign: campaign)
      faction2 = Faction.create!(name: "The Lotus", campaign: campaign)
      
      # Create junctures with faction associations (this was causing the foreign key error)
      juncture1 = Juncture.create!(name: "Contemporary", campaign: campaign, faction: faction1)
      juncture2 = Juncture.create!(name: "Ancient", campaign: campaign, faction: faction2)
      juncture3 = Juncture.create!(name: "Future", campaign: campaign, faction: faction1)
      
      # Create characters with faction associations
      character1 = Character.create!(name: "Character 1", campaign: campaign, faction: faction1, action_values: {})
      character2 = Character.create!(name: "Character 2", campaign: campaign, faction: faction2, action_values: {})
      
      # This should not raise any foreign key constraint errors
      expect { service.send(:handle_associations, campaign) }.not_to raise_error
      
      # Everything should be deleted
      expect { faction1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { faction2.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { character1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { character2.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { juncture1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { juncture2.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { juncture3.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
    
    it 'specifically handles junctures with faction associations without foreign key errors' do
      # Create multiple factions
      faction1 = Faction.create!(name: "The Dragons", campaign: campaign)
      faction2 = Faction.create!(name: "The Lotus", campaign: campaign)
      faction3 = Faction.create!(name: "The Jammers", campaign: campaign)
      
      # Create junctures, all associated with factions
      juncture1 = Juncture.create!(name: "Contemporary", campaign: campaign, faction: faction1)
      juncture2 = Juncture.create!(name: "Ancient", campaign: campaign, faction: faction2)
      juncture3 = Juncture.create!(name: "Future", campaign: campaign, faction: faction3)
      juncture4 = Juncture.create!(name: "1850s", campaign: campaign, faction: faction1)
      
      # Verify associations are set
      expect(juncture1.faction_id).to eq(faction1.id)
      expect(juncture2.faction_id).to eq(faction2.id)
      expect(juncture3.faction_id).to eq(faction3.id)
      expect(juncture4.faction_id).to eq(faction1.id)
      
      # This should handle the foreign key constraint properly
      expect { service.send(:handle_associations, campaign) }.not_to raise_error
      
      # Verify all junctures are deleted
      expect(Juncture.where(campaign_id: campaign.id).count).to eq(0)
      
      # Verify all factions are deleted
      expect(Faction.where(campaign_id: campaign.id).count).to eq(0)
    end
    
    it 'handles schtick associations correctly' do
      # Create schticks for the campaign
      schtick1 = Schtick.create!(name: "Lightning Strike", campaign: campaign, category: "Martial Arts", path: "martial_arts")
      schtick2 = Schtick.create!(name: "Both Guns Blazing", campaign: campaign, category: "Guns", path: "guns")
      
      # Create characters
      character1 = Character.create!(name: "Hero", campaign: campaign, action_values: {})
      character2 = Character.create!(name: "Sidekick", campaign: campaign, action_values: {})
      
      # Associate schticks with characters
      CharacterSchtick.create!(character: character1, schtick: schtick1)
      CharacterSchtick.create!(character: character1, schtick: schtick2)
      CharacterSchtick.create!(character: character2, schtick: schtick1)
      
      # Verify associations exist
      expect(CharacterSchtick.where(schtick_id: schtick1.id).count).to eq(2)
      expect(CharacterSchtick.where(schtick_id: schtick2.id).count).to eq(1)
      
      # This should not raise foreign key constraint errors
      expect { service.send(:handle_associations, campaign) }.not_to raise_error
      
      # Verify everything is deleted
      expect(CharacterSchtick.where(schtick_id: [schtick1.id, schtick2.id]).count).to eq(0)
      expect(Schtick.where(campaign_id: campaign.id).count).to eq(0)
      expect(Character.where(campaign_id: campaign.id).count).to eq(0)
    end
    
    it 'handles cross-campaign weapon carries' do
      # Create another campaign and user
      other_user = User.create!(email: "other@example.com", first_name: "Other", last_name: "User", gamemaster: true, confirmed_at: Time.now)
      other_campaign = Campaign.create!(name: "Other Campaign", user: other_user)
      
      # Create weapon in THIS campaign
      weapon = Weapon.create!(name: "Shared Sword", campaign: campaign, damage: "+3")
      
      # Create character in OTHER campaign
      other_character = Character.create!(name: "Other Hero", campaign: other_campaign, action_values: {})
      
      # Character from other campaign carries weapon from this campaign (data integrity issue)
      carry = Carry.create!(character: other_character, weapon: weapon)
      
      # This should handle the cross-campaign reference without errors
      expect { service.send(:handle_associations, campaign) }.not_to raise_error
      
      # Verify the carry is deleted even though character is from different campaign
      expect(Carry.exists?(carry.id)).to be false
      
      # Verify weapon is deleted
      expect(Weapon.where(campaign_id: campaign.id).count).to eq(0)
      
      # Other campaign's character should still exist
      expect { other_character.reload }.not_to raise_error
    end
    
    it 'handles all juncture-faction references properly' do
      # Create factions in THIS campaign
      faction1 = Faction.create!(name: "Dragons", campaign: campaign)
      faction2 = Faction.create!(name: "Lotus", campaign: campaign)
      
      # Create junctures in THIS campaign that reference factions
      juncture1 = Juncture.create!(name: "Contemporary", campaign: campaign, faction: faction1)
      juncture2 = Juncture.create!(name: "Ancient", campaign: campaign, faction: faction2)
      juncture3 = Juncture.create!(name: "Future", campaign: campaign, faction: faction1)
      
      # Verify associations are set
      expect(juncture1.faction_id).to eq(faction1.id)
      expect(juncture2.faction_id).to eq(faction2.id)
      expect(juncture3.faction_id).to eq(faction1.id)
      
      # This should handle all faction references without errors
      expect { service.send(:handle_associations, campaign) }.not_to raise_error
      
      # Verify all junctures and factions are deleted
      expect(Juncture.where(campaign_id: campaign.id).count).to eq(0)
      expect(Faction.where(campaign_id: campaign.id).count).to eq(0)
    end
    
    it 'handles weapon-carry associations correctly' do
      # Create weapons for the campaign
      weapon1 = Weapon.create!(name: "Sword", campaign: campaign, damage: "+3")
      weapon2 = Weapon.create!(name: "Gun", campaign: campaign, damage: "+2")
      
      # Create characters
      character1 = Character.create!(name: "Hero", campaign: campaign, action_values: {})
      character2 = Character.create!(name: "Sidekick", campaign: campaign, action_values: {})
      
      # Associate weapons with characters
      Carry.create!(character: character1, weapon: weapon1)
      Carry.create!(character: character1, weapon: weapon2)
      Carry.create!(character: character2, weapon: weapon1)
      
      # Verify associations exist
      expect(Carry.where(weapon_id: weapon1.id).count).to eq(2)
      expect(Carry.where(weapon_id: weapon2.id).count).to eq(1)
      
      # This should not raise foreign key constraint errors
      expect { service.send(:handle_associations, campaign) }.not_to raise_error
      
      # Verify everything is deleted
      expect(Carry.where(weapon_id: [weapon1.id, weapon2.id]).count).to eq(0)
      expect(Weapon.where(campaign_id: campaign.id).count).to eq(0)
      expect(Character.where(campaign_id: campaign.id).count).to eq(0)
    end
    
    it 'handles fight events correctly' do
      # Create a fight
      fight = Fight.create!(name: "Epic Battle", campaign: campaign, sequence: 1)
      
      # Create characters
      character1 = Character.create!(name: "Hero", campaign: campaign, action_values: {})
      character2 = Character.create!(name: "Villain", campaign: campaign, action_values: {})
      
      # Add characters to fight
      shot1 = Shot.create!(fight: fight, character: character1, shot: 10)
      shot2 = Shot.create!(fight: fight, character: character2, shot: 15)
      
      # Create fight events
      event1 = FightEvent.create!(fight: fight, event_type: "action", description: "Hero attacks", details: {})
      event2 = FightEvent.create!(fight: fight, event_type: "action", description: "Villain counters", details: {})
      
      # Verify associations exist
      expect(FightEvent.where(fight_id: fight.id).count).to eq(2)
      expect(Shot.where(fight_id: fight.id).count).to eq(2)
      
      # This should not raise foreign key constraint errors
      expect { service.send(:handle_associations, campaign) }.not_to raise_error
      
      # Verify everything is deleted
      expect(FightEvent.where(fight_id: fight.id).count).to eq(0)
      expect(Shot.where(fight_id: fight.id).count).to eq(0)
      expect(Fight.where(campaign_id: campaign.id).count).to eq(0)
    end
    
    it 'handles join tables correctly' do
      # Create entities
      faction = Faction.create!(name: "Faction", campaign: campaign)
      character = Character.create!(name: "Character", campaign: campaign, faction: faction, action_values: {})
      vehicle = Vehicle.create!(name: "Vehicle", campaign: campaign, action_values: {})
      party = Party.create!(name: "Party", campaign: campaign)
      site = Site.create!(name: "Site", campaign: campaign)
      weapon = Weapon.create!(name: "Weapon", campaign: campaign, damage: "+2")
      
      # Create join table records
      membership = Membership.create!(party: party, character: character)
      vehicle_membership = Membership.create!(party: party, vehicle: vehicle)
      carry = Carry.create!(character: character, weapon: weapon)
      attunement = Attunement.create!(character: character, site: site)
      campaign_membership = CampaignMembership.create!(campaign: campaign, user: user)
      
      service.send(:handle_associations, campaign)
      
      # All join table records should be deleted
      expect(Membership.exists?(membership.id)).to be false
      expect(Membership.exists?(vehicle_membership.id)).to be false
      expect(Carry.exists?(carry.id)).to be false
      expect(Attunement.exists?(attunement.id)).to be false
      expect(CampaignMembership.exists?(campaign_membership.id)).to be false
    end
  end
  
  describe '#entity_type_name' do
    it 'returns campaign' do
      expect(service.send(:entity_type_name)).to eq('campaign')
    end
  end
  
  describe '#delete' do
    context 'when campaign has no associations' do
      it 'deletes the campaign successfully' do
        result = service.delete(campaign)
        
        expect(result[:success]).to be true
        expect(result[:message]).to eq('Entity successfully deleted')
        expect(Campaign.find_by(id: campaign.id)).to be_nil
      end
    end
    
    context 'when campaign has associations and force is false' do
      before do
        Character.create!(name: "Character", campaign: campaign, action_values: {})
        Fight.create!(name: "Fight", campaign: campaign, sequence: 1)
      end
      
      it 'returns unified error response with constraint details' do
        result = service.delete(campaign, force: false)
        
        expect(result[:success]).to be false
        expect(result[:error][:error_type]).to eq('associations_exist')
        expect(result[:error][:entity_type]).to eq('campaign')
        expect(result[:error][:entity_id]).to eq(campaign.id)
        expect(result[:error][:constraints]['characters'][:count]).to eq(1)
        expect(result[:error][:constraints]['fights'][:count]).to eq(1)
        expect(result[:error][:suggestions]).to include('Use force=true parameter to cascade delete')
        expect(Campaign.find_by(id: campaign.id)).to be_present
      end
    end
    
    context 'when campaign has associations and force is true' do
      let!(:character) { Character.create!(name: "Character", campaign: campaign, action_values: {}) }
      let!(:fight) { Fight.create!(name: "Fight", campaign: campaign, sequence: 1) }
      
      it 'deletes the campaign and all associations' do
        result = service.delete(campaign, force: true)
        
        expect(result[:success]).to be true
        expect(Campaign.find_by(id: campaign.id)).to be_nil
        # Associated records should be deleted
        expect { character.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { fight.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
    
    context 'when campaign has complex associations like Production Test campaign' do
      # This mimics the exact scenario from the production campaign that was failing
      let!(:faction1) { Faction.create!(name: "The Dragons", campaign: campaign) }
      let!(:faction2) { Faction.create!(name: "The Lotus", campaign: campaign) }
      
      let!(:juncture1) { Juncture.create!(name: "Contemporary", campaign: campaign, faction: faction1) }
      let!(:juncture2) { Juncture.create!(name: "Ancient", campaign: campaign, faction: faction2) }
      let!(:juncture3) { Juncture.create!(name: "Future", campaign: campaign, faction: faction2) }
      
      let!(:character1) { Character.create!(name: "Hero", campaign: campaign, faction: faction1, juncture: juncture1, action_values: {}) }
      let!(:character2) { Character.create!(name: "Villain", campaign: campaign, faction: faction2, juncture: juncture2, action_values: {}) }
      let!(:character3) { Character.create!(name: "Sidekick", campaign: campaign, juncture: juncture3, action_values: {}) }
      
      let!(:vehicle) { Vehicle.create!(name: "Car", campaign: campaign, action_values: {}) }
      let!(:fight) { Fight.create!(name: "Big Battle", campaign: campaign, sequence: 1) }
      let!(:site1) { Site.create!(name: "Temple", campaign: campaign) }
      let!(:site2) { Site.create!(name: "Palace", campaign: campaign) }
      let!(:party1) { Party.create!(name: "Heroes", campaign: campaign) }
      let!(:party2) { Party.create!(name: "Villains", campaign: campaign) }
      
      let!(:weapon1) { Weapon.create!(name: "Sword", campaign: campaign, damage: "+3") }
      let!(:weapon2) { Weapon.create!(name: "Gun", campaign: campaign, damage: "+2") }
      let!(:weapon3) { Weapon.create!(name: "Staff", campaign: campaign, damage: "+1") }
      
      let!(:schtick1) { Schtick.create!(name: "Lightning Fist", campaign: campaign, category: "Martial Arts", path: "martial_arts") }
      let!(:schtick2) { Schtick.create!(name: "Both Guns Blazing", campaign: campaign, category: "Guns", path: "guns") }
      
      # Character-Schtick associations
      before do
        character1.schticks << schtick1
        character2.schticks << [schtick1, schtick2]
      end
      
      # Join tables - comprehensive associations
      let!(:membership1) { Membership.create!(party: party1, character: character1) }
      let!(:membership2) { Membership.create!(party: party1, character: character3) }
      let!(:membership3) { Membership.create!(party: party2, character: character2) }
      let!(:membership4) { Membership.create!(party: party1, vehicle: vehicle) }
      
      let!(:carry1) { Carry.create!(character: character1, weapon: weapon1) }
      let!(:carry2) { Carry.create!(character: character1, weapon: weapon2) }
      let!(:carry3) { Carry.create!(character: character2, weapon: weapon3) }
      let!(:carry4) { Carry.create!(character: character3, weapon: weapon2) }
      
      let!(:attunement1) { Attunement.create!(character: character1, site: site1) }
      let!(:attunement2) { Attunement.create!(character: character2, site: site2) }
      let!(:attunement3) { Attunement.create!(character: character3, site: site1) }
      
      let!(:campaign_membership) { CampaignMembership.create!(campaign: campaign, user: user) }
      
      # Add characters to fight
      let!(:shot1) { Shot.create!(fight: fight, character: character1, shot: 10) }
      let!(:shot2) { Shot.create!(fight: fight, character: character2, shot: 15) }
      let!(:shot3) { Shot.create!(fight: fight, vehicle: vehicle, shot: 20) }
      
      it 'successfully deletes everything without foreign key or null constraint violations' do
        # This should work without any database errors
        result = service.delete(campaign, force: true)
        
        expect(result[:success]).to be true
        expect(result[:message]).to eq('Entity successfully deleted')
        
        # Verify everything is gone
        expect(Campaign.exists?(campaign.id)).to be false
        expect(Faction.where(campaign_id: campaign.id).count).to eq(0)
        expect(Juncture.where(campaign_id: campaign.id).count).to eq(0)
        expect(Character.where(campaign_id: campaign.id).count).to eq(0)
        expect(Vehicle.where(campaign_id: campaign.id).count).to eq(0)
        expect(Fight.where(campaign_id: campaign.id).count).to eq(0)
        expect(Site.where(campaign_id: campaign.id).count).to eq(0)
        expect(Party.where(campaign_id: campaign.id).count).to eq(0)
        expect(Weapon.where(campaign_id: campaign.id).count).to eq(0)
        
        # Verify join tables are cleaned
        expect(Membership.exists?(membership1.id)).to be false
        expect(Carry.exists?(carry1.id)).to be false
        expect(Attunement.exists?(attunement1.id)).to be false
        expect(CampaignMembership.exists?(campaign_membership.id)).to be false
      end
    end
  end
end