class AddIndexesToActiveColumns < ActiveRecord::Migration[8.0]
  def change
    # Add indexes for active column on all tables that have it
    # This improves performance for filtering by active status
    
    # Tables that need active column indexes
    tables_needing_indexes = %w[
      characters
      vehicles
      weapons
      schticks
      sites
      factions
      parties
      junctures
      fights
    ]
    
    tables_needing_indexes.each do |table_name|
      if table_exists?(table_name) && column_exists?(table_name, :active)
        unless index_exists?(table_name, :active)
          add_index table_name, :active, algorithm: :concurrently if index_method_supported?(:concurrently)
          add_index table_name, :active unless index_exists?(table_name, :active)
          puts "Added index on #{table_name}.active"
        else
          puts "Index already exists on #{table_name}.active"
        end
        
        # Add composite indexes for common query patterns
        case table_name
        when 'characters'
          unless index_exists?(:characters, [:campaign_id, :active])
            add_index :characters, [:campaign_id, :active], algorithm: :concurrently if index_method_supported?(:concurrently)
            add_index :characters, [:campaign_id, :active] unless index_exists?(:characters, [:campaign_id, :active])
          end
        when 'fights'
          unless index_exists?(:fights, [:campaign_id, :active])
            add_index :fights, [:campaign_id, :active], algorithm: :concurrently if index_method_supported?(:concurrently)
            add_index :fights, [:campaign_id, :active] unless index_exists?(:fights, [:campaign_id, :active])
          end
        when 'vehicles'
          unless index_exists?(:vehicles, [:campaign_id, :active])
            add_index :vehicles, [:campaign_id, :active], algorithm: :concurrently if index_method_supported?(:concurrently)
            add_index :vehicles, [:campaign_id, :active] unless index_exists?(:vehicles, [:campaign_id, :active])
          end
        when 'sites'
          unless index_exists?(:sites, [:campaign_id, :active])
            add_index :sites, [:campaign_id, :active], algorithm: :concurrently if index_method_supported?(:concurrently)
            add_index :sites, [:campaign_id, :active] unless index_exists?(:sites, [:campaign_id, :active])
          end
        when 'factions'
          unless index_exists?(:factions, [:campaign_id, :active])
            add_index :factions, [:campaign_id, :active], algorithm: :concurrently if index_method_supported?(:concurrently)
            add_index :factions, [:campaign_id, :active] unless index_exists?(:factions, [:campaign_id, :active])
          end
        when 'parties'
          unless index_exists?(:parties, [:campaign_id, :active])
            add_index :parties, [:campaign_id, :active], algorithm: :concurrently if index_method_supported?(:concurrently)
            add_index :parties, [:campaign_id, :active] unless index_exists?(:parties, [:campaign_id, :active])
          end
        when 'weapons'
          unless index_exists?(:weapons, [:campaign_id, :active])
            add_index :weapons, [:campaign_id, :active], algorithm: :concurrently if index_method_supported?(:concurrently)
            add_index :weapons, [:campaign_id, :active] unless index_exists?(:weapons, [:campaign_id, :active])
          end
        when 'schticks'
          unless index_exists?(:schticks, [:campaign_id, :active])
            add_index :schticks, [:campaign_id, :active], algorithm: :concurrently if index_method_supported?(:concurrently)
            add_index :schticks, [:campaign_id, :active] unless index_exists?(:schticks, [:campaign_id, :active])
          end
        when 'junctures'
          unless index_exists?(:junctures, [:campaign_id, :active])
            add_index :junctures, [:campaign_id, :active], algorithm: :concurrently if index_method_supported?(:concurrently)
            add_index :junctures, [:campaign_id, :active] unless index_exists?(:junctures, [:campaign_id, :active])
          end
        end
      end
    end
    
    # Note: campaigns table already has index on [:active, :created_at] which is sufficient
  end
  
  private
  
  def index_method_supported?(method)
    # Check if we can use concurrent index creation (available in production)
    # In development/test we'll use regular index creation
    connection.supports_concurrent_index_creation? && method == :concurrently rescue false
  end
end