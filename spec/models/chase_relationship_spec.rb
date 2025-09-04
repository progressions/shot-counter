require 'rails_helper'

RSpec.describe ChaseRelationship, type: :model do
  let!(:user) { User.create!(email: "test@example.com", first_name: "Test", last_name: "User", confirmed_at: Time.now) }
  let!(:campaign) { user.campaigns.create!(name: "Test Campaign") }
  let!(:fight) { campaign.fights.create!(name: "Chase Scene") }
  let!(:pursuer) { campaign.vehicles.create!(name: "Police Car") }
  let!(:evader) { campaign.vehicles.create!(name: "Getaway Van") }

  describe 'associations' do
    let!(:relationship) { ChaseRelationship.create!(pursuer: pursuer, evader: evader, fight: fight) }
    
    it 'belongs to a pursuer (Vehicle)' do
      expect(relationship.pursuer).to eq(pursuer)
      expect(relationship.pursuer).to be_a(Vehicle)
    end

    it 'belongs to an evader (Vehicle)' do
      expect(relationship.evader).to eq(evader)
      expect(relationship.evader).to be_a(Vehicle)
    end

    it 'belongs to a fight' do
      expect(relationship.fight).to eq(fight)
    end
  end

  describe 'validations' do
    it 'validates presence of position' do
      relationship = ChaseRelationship.new(pursuer: pursuer, evader: evader, fight: fight)
      relationship.position = nil
      expect(relationship).not_to be_valid
      expect(relationship.errors[:position]).to include("can't be blank")
    end

    it 'validates position is near or far' do
      relationship = ChaseRelationship.new(pursuer: pursuer, evader: evader, fight: fight)
      relationship.position = 'invalid'
      expect(relationship).not_to be_valid
      expect(relationship.errors[:position]).to include("is not included in the list")
    end
    
    it 'validates that pursuer and evader are different vehicles' do
      relationship = ChaseRelationship.new(pursuer: pursuer, evader: pursuer, fight: fight)
      expect(relationship).not_to be_valid
      expect(relationship.errors[:evader_id]).to include("can't be the same as pursuer")
    end

    it 'enforces unique active relationships between vehicle pairs in a fight' do
      ChaseRelationship.create!(pursuer: pursuer, evader: evader, fight: fight, active: true)
      duplicate = ChaseRelationship.new(pursuer: pursuer, evader: evader, fight: fight, active: true)
      
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:pursuer_id]).to include('already has an active relationship with this evader in this fight')
    end

    it 'allows inactive duplicate relationships' do
      ChaseRelationship.create!(pursuer: pursuer, evader: evader, fight: fight, active: false)
      duplicate = ChaseRelationship.new(pursuer: pursuer, evader: evader, fight: fight, active: false)
      
      expect(duplicate).to be_valid
    end

    it 'allows relationships in different fights' do
      other_fight = campaign.fights.create!(name: "Other Chase")
      ChaseRelationship.create!(pursuer: pursuer, evader: evader, fight: fight)
      relationship = ChaseRelationship.new(pursuer: pursuer, evader: evader, fight: other_fight)
      
      expect(relationship).to be_valid
    end
  end

  describe 'defaults' do
    it 'defaults position to far' do
      relationship = ChaseRelationship.new
      expect(relationship.position).to eq('far')
    end

    it 'defaults active to true' do
      relationship = ChaseRelationship.new
      expect(relationship.active).to be true
    end
  end

  describe 'scopes' do
    let!(:active_relationship) { ChaseRelationship.create!(pursuer: pursuer, evader: evader, fight: fight, active: true) }
    let!(:inactive_relationship) { ChaseRelationship.create!(pursuer: campaign.vehicles.create!(name: "Car 2"), evader: campaign.vehicles.create!(name: "Car 3"), fight: fight, active: false) }
    let!(:other_fight) { campaign.fights.create!(name: "Other Fight") }
    let!(:other_fight_relationship) { ChaseRelationship.create!(pursuer: campaign.vehicles.create!(name: "Car 4"), evader: campaign.vehicles.create!(name: "Car 5"), fight: other_fight, active: true) }

    describe '.active' do
      it 'returns only active relationships' do
        expect(ChaseRelationship.active).to include(active_relationship, other_fight_relationship)
        expect(ChaseRelationship.active).not_to include(inactive_relationship)
      end
    end

    describe '.for_fight' do
      it 'returns relationships for a specific fight' do
        expect(ChaseRelationship.for_fight(fight)).to include(active_relationship, inactive_relationship)
        expect(ChaseRelationship.for_fight(fight)).not_to include(other_fight_relationship)
      end
    end

    describe '.for_vehicle' do
      it 'returns relationships where vehicle is pursuer or evader' do
        as_evader = ChaseRelationship.create!(pursuer: campaign.vehicles.create!(name: "Car 6"), evader: pursuer, fight: fight, active: true)
        unrelated = ChaseRelationship.create!(pursuer: campaign.vehicles.create!(name: "Car 7"), evader: campaign.vehicles.create!(name: "Car 8"), fight: fight, active: true)

        expect(ChaseRelationship.for_vehicle(pursuer)).to include(active_relationship, as_evader)
        expect(ChaseRelationship.for_vehicle(pursuer)).not_to include(unrelated)
      end
    end
  end

  describe '#near?' do
    it 'returns true when position is near' do
      relationship = ChaseRelationship.new(position: 'near')
      expect(relationship.near?).to be true
    end

    it 'returns false when position is far' do
      relationship = ChaseRelationship.new(position: 'far')
      expect(relationship.near?).to be false
    end
  end

  describe '#far?' do
    it 'returns true when position is far' do
      relationship = ChaseRelationship.new(position: 'far')
      expect(relationship.far?).to be true
    end

    it 'returns false when position is near' do
      relationship = ChaseRelationship.new(position: 'near')
      expect(relationship.far?).to be false
    end
  end
end