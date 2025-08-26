require 'rails_helper'

RSpec.describe 'Active field migration' do
  let(:user) do
    User.first || User.create!(
      email: 'test@example.com',
      password: 'password123',
      first_name: 'Test',
      last_name: 'User'
    )
  end
  let(:campaign) { Campaign.create!(name: 'Test Campaign', user: user) }

  describe 'active field defaults' do
    it 'sets active to true by default for new sites' do
      site = Site.create!(
        name: 'Test Site',
        campaign: campaign
      )
      
      expect(site.active).to be true
    end

    it 'sets active to true by default for new parties' do
      party = Party.create!(
        name: 'Test Party',
        campaign: campaign
      )
      
      expect(party.active).to be true
    end

    it 'sets active to true by default for new characters' do
      character = Character.create!(
        name: 'Test Character',
        campaign: campaign
      )
      
      expect(character.active).to be true
    end

    it 'sets active to true by default for new vehicles' do
      vehicle = Vehicle.create!(
        name: 'Test Vehicle',
        campaign: campaign,
        action_values: { speed: 10 }
      )
      
      expect(vehicle.active).to be true
    end

    it 'sets active to true by default for new weapons' do
      weapon = Weapon.create!(
        name: 'Test Weapon',
        campaign: campaign,
        damage: 10
      )
      
      expect(weapon.active).to be true
    end

    it 'sets active to true by default for new schticks' do
      schtick = Schtick.create!(
        name: 'Test Schtick',
        campaign: campaign,
        category: 'Guns'
      )
      
      expect(schtick.active).to be true
    end

    it 'sets active to true by default for new factions' do
      faction = Faction.create!(
        name: 'Test Faction',
        campaign: campaign
      )
      
      expect(faction.active).to be true
    end

    it 'sets active to true by default for new fights' do
      fight = Fight.create!(
        name: 'Test Fight',
        campaign: campaign
      )
      
      expect(fight.active).to be true
    end

    it 'sets active to true by default for new junctures' do
      juncture = Juncture.create!(
        name: 'Test Juncture',
        campaign: campaign
      )
      
      expect(juncture.active).to be true
    end
  end

  describe 'filtering behavior' do
    it 'allows entities to be marked as inactive' do
      character = Character.create!(
        name: 'Hidden Character',
        campaign: campaign,
        active: false
      )
      
      expect(character.active).to be false
    end
  end
  
  describe 'deprecated fields removal' do
    it 'removes secret field from sites table' do
      # After migration, secret field should not exist
      expect(ActiveRecord::Base.connection.column_exists?(:sites, :secret)).to be false
    end
    
    it 'removes secret field from parties table' do
      # After migration, secret field should not exist
      expect(ActiveRecord::Base.connection.column_exists?(:parties, :secret)).to be false
    end
    
    it 'removes hidden field from any table that had it' do
      # After migration, hidden field should not exist on any entity table
      %w[characters vehicles weapons schticks sites factions parties junctures fights campaigns].each do |table_name|
        expect(ActiveRecord::Base.connection.column_exists?(table_name, :hidden)).to be false
      end
    end
  end
end