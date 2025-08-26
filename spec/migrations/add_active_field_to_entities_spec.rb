require 'rails_helper'

RSpec.describe 'AddActiveFieldToEntities migration' do
  # Test that the migration properly adds active fields and indexes
  
  it 'ensures schticks table has active column' do
    expect(ActiveRecord::Base.connection.column_exists?(:schticks, :active)).to be true
    
    column = Schtick.columns.find { |c| c.name == 'active' }
    expect(column).not_to be_nil
    expect(column.type).to eq :boolean
    expect(column.default).to eq 'true'
    expect(column.null).to be false
  end

  it 'ensures weapons table has active column' do
    expect(ActiveRecord::Base.connection.column_exists?(:weapons, :active)).to be true
    
    column = Weapon.columns.find { |c| c.name == 'active' }
    expect(column).not_to be_nil
    expect(column.type).to eq :boolean
    expect(column.default).to eq 'true'
    expect(column.null).to be false
  end

  it 'ensures junctures table has active column with proper default' do
    expect(ActiveRecord::Base.connection.column_exists?(:junctures, :active)).to be true
    
    column = Juncture.columns.find { |c| c.name == 'active' }
    expect(column).not_to be_nil
    expect(column.type).to eq :boolean
    expect(column.default).to eq 'true'
    expect(column.null).to be false
  end

  it 'has indexes on active columns for performance' do
    expect(ActiveRecord::Base.connection.index_exists?(:schticks, :active)).to be true
    expect(ActiveRecord::Base.connection.index_exists?(:weapons, :active)).to be true
    expect(ActiveRecord::Base.connection.index_exists?(:junctures, :active)).to be true
    expect(ActiveRecord::Base.connection.index_exists?(:characters, :active)).to be true
    expect(ActiveRecord::Base.connection.index_exists?(:vehicles, :active)).to be true
    expect(ActiveRecord::Base.connection.index_exists?(:fights, :active)).to be true
    expect(ActiveRecord::Base.connection.index_exists?(:sites, :active)).to be true
    expect(ActiveRecord::Base.connection.index_exists?(:factions, :active)).to be true
    expect(ActiveRecord::Base.connection.index_exists?(:parties, :active)).to be true
  end

  it 'has composite indexes for common query patterns' do
    expect(ActiveRecord::Base.connection.index_exists?(:weapons, [:campaign_id, :active])).to be true
    expect(ActiveRecord::Base.connection.index_exists?(:schticks, [:campaign_id, :active])).to be true
    expect(ActiveRecord::Base.connection.index_exists?(:sites, [:campaign_id, :active])).to be true
    expect(ActiveRecord::Base.connection.index_exists?(:factions, [:campaign_id, :active])).to be true
    expect(ActiveRecord::Base.connection.index_exists?(:parties, [:campaign_id, :active])).to be true
    expect(ActiveRecord::Base.connection.index_exists?(:junctures, [:campaign_id, :active])).to be true
  end

  it 'ensures all entity tables have consistent active field settings' do
    %w[campaigns characters factions fights parties sites vehicles].each do |table_name|
      expect(ActiveRecord::Base.connection.column_exists?(table_name, :active)).to be true
      
      column = ActiveRecord::Base.connection.columns(table_name).find { |c| c.name == 'active' }
      expect(column).not_to be_nil
      expect(column.type).to eq :boolean
      expect(column.default).to eq 'true'
      expect(column.null).to be false
    end
  end
end