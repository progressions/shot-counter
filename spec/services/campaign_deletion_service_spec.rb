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
    it 'nullifies campaign_id for all associated records' do
      character = Character.create!(name: "Character", campaign: campaign, action_values: {})
      vehicle = Vehicle.create!(name: "Vehicle", campaign: campaign, action_values: {})
      fight = Fight.create!(name: "Fight", campaign: campaign, sequence: 1)
      site = Site.create!(name: "Site", campaign: campaign)
      party = Party.create!(name: "Party", campaign: campaign)
      faction = Faction.create!(name: "Faction", campaign: campaign)
      juncture = Juncture.create!(name: "Contemporary", campaign: campaign)
      
      service.send(:handle_associations, campaign)
      
      expect(character.reload.campaign_id).to be_nil
      expect(vehicle.reload.campaign_id).to be_nil
      expect(fight.reload.campaign_id).to be_nil
      expect(site.reload.campaign_id).to be_nil
      expect(juncture.reload.campaign_id).to be_nil
      # Parties and factions should be destroyed (non-null constraint)
      expect { party.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { faction.reload }.to raise_error(ActiveRecord::RecordNotFound)
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
      
      it 'deletes the campaign and nullifies associations' do
        result = service.delete(campaign, force: true)
        
        expect(result[:success]).to be true
        expect(Campaign.find_by(id: campaign.id)).to be_nil
        expect(character.reload.campaign_id).to be_nil
        expect(fight.reload.campaign_id).to be_nil
      end
    end
  end
end