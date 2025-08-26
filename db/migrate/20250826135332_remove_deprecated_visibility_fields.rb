class RemoveDeprecatedVisibilityFields < ActiveRecord::Migration[8.0]
  def change
    # Remove secret field from parties and sites tables
    if column_exists?(:parties, :secret)
      remove_column :parties, :secret, :boolean
      puts "Removed secret column from parties table"
    end
    
    if column_exists?(:sites, :secret)
      remove_column :sites, :secret, :boolean
      puts "Removed secret column from sites table"
    end
    
    # Remove hidden field if it exists on any table
    # Check common tables that might have had hidden field
    %w[characters vehicles weapons schticks sites factions parties junctures fights campaigns].each do |table_name|
      if table_exists?(table_name) && column_exists?(table_name, :hidden)
        remove_column table_name, :hidden, :boolean
        puts "Removed hidden column from #{table_name} table"
      end
    end
  end
end