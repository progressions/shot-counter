require 'rails_helper'

RSpec.describe EntityDeletionService do
  let(:user) { User.create!(email: "test@example.com", first_name: "Test", last_name: "User", gamemaster: true, confirmed_at: Time.now) }
  let(:campaign) { Campaign.create!(name: "Test Campaign", user: user) }
  
  describe '#unified_error_response' do
    let(:service) { described_class.new }
    
    it 'returns a standardized error response structure' do
      constraints = {
        'characters' => { count: 5, label: 'characters' },
        'fights' => { count: 2, label: 'active fights' }
      }
      
      response = service.send(:unified_error_response, 
        entity_type: 'campaign',
        entity_id: '123-456',
        constraints: constraints
      )
      
      expect(response[:error_type]).to eq('associations_exist')
      expect(response[:entity_type]).to eq('campaign')
      expect(response[:entity_id]).to eq('123-456')
      expect(response[:constraints]).to eq(constraints)
      expect(response[:suggestions]).to include('Remove or reassign associated records first')
      expect(response[:suggestions]).to include('Use force=true parameter to cascade delete')
    end
  end
  
  describe '#check_constraints' do
    let(:service) { described_class.new }
    
    it 'returns empty hash when no associations exist' do
      allow(service).to receive(:association_counts).and_return({})
      
      constraints = service.send(:check_constraints, campaign)
      expect(constraints).to eq({})
    end
    
    it 'returns association counts when associations exist' do
      allow(service).to receive(:association_counts).and_return({
        'characters' => { count: 3, label: 'characters' },
        'fights' => { count: 1, label: 'active fights' }
      })
      
      constraints = service.send(:check_constraints, campaign)
      expect(constraints['characters'][:count]).to eq(3)
      expect(constraints['fights'][:count]).to eq(1)
    end
  end
  
  describe '#can_delete?' do
    let(:service) { described_class.new }
    
    context 'when force is true' do
      it 'returns true regardless of associations' do
        allow(service).to receive(:check_constraints).and_return({
          'characters' => { count: 5, label: 'characters' }
        })
        
        expect(service.send(:can_delete?, campaign, force: true)).to be true
      end
    end
    
    context 'when force is false' do
      it 'returns true when no associations exist' do
        allow(service).to receive(:check_constraints).and_return({})
        
        expect(service.send(:can_delete?, campaign, force: false)).to be true
      end
      
      it 'returns false when associations exist' do
        allow(service).to receive(:check_constraints).and_return({
          'characters' => { count: 1, label: 'characters' }
        })
        
        expect(service.send(:can_delete?, campaign, force: false)).to be false
      end
    end
  end
  
  describe '#perform_deletion' do
    let(:service) { described_class.new }
    
    context 'when deletion is allowed' do
      it 'deletes the entity and returns success' do
        allow(service).to receive(:can_delete?).and_return(true)
        allow(service).to receive(:handle_associations)
        allow(campaign).to receive(:destroy!).and_return(true)
        
        result = service.send(:perform_deletion, campaign, force: false)
        
        expect(result[:success]).to be true
        expect(result[:message]).to eq('Entity successfully deleted')
      end
    end
    
    context 'when deletion is blocked' do
      it 'returns standardized error response' do
        constraints = { 'characters' => { count: 2, label: 'characters' } }
        allow(service).to receive(:can_delete?).and_return(false)
        allow(service).to receive(:check_constraints).and_return(constraints)
        allow(service).to receive(:entity_type_name).and_return('campaign')
        
        result = service.send(:perform_deletion, campaign, force: false)
        
        expect(result[:success]).to be false
        expect(result[:error][:error_type]).to eq('associations_exist')
        expect(result[:error][:constraints]).to eq(constraints)
      end
    end
  end
  
  describe 'Subclass implementation' do
    # Test that subclasses must implement required methods
    class TestDeletionService < EntityDeletionService
      # Intentionally not implementing required methods for testing
    end
    
    let(:service) { TestDeletionService.new }
    
    it 'raises NotImplementedError for association_counts' do
      expect { service.send(:association_counts, campaign) }.to raise_error(NotImplementedError)
    end
    
    it 'raises NotImplementedError for handle_associations' do
      expect { service.send(:handle_associations, campaign) }.to raise_error(NotImplementedError)
    end
    
    it 'raises NotImplementedError for entity_type_name' do
      expect { service.send(:entity_type_name) }.to raise_error(NotImplementedError)
    end
  end
end