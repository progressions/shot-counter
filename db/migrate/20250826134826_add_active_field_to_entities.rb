class AddActiveFieldToEntities < ActiveRecord::Migration[8.0]
  def change
    # Add active field to tables that don't have it
    unless column_exists?(:schticks, :active)
      add_column :schticks, :active, :boolean, default: true, null: false
    end

    unless column_exists?(:weapons, :active)
      add_column :weapons, :active, :boolean, default: true, null: false
    end

    # Update junctures table to have proper default for active field
    if column_exists?(:junctures, :active)
      # First set all NULL values to true
      execute "UPDATE junctures SET active = true WHERE active IS NULL"
      # Then change the column to have default and not null
      change_column :junctures, :active, :boolean, default: true, null: false
    else
      add_column :junctures, :active, :boolean, default: true, null: false
    end

    # Ensure all other tables have consistent active field settings
    # These tables already have active field, but ensure consistency
    tables_with_active = %w[campaigns characters factions fights parties sites vehicles]
    
    tables_with_active.each do |table_name|
      if column_exists?(table_name, :active)
        # Set any NULL values to true
        execute "UPDATE #{table_name} SET active = true WHERE active IS NULL"
        # Ensure column has proper default and constraints
        change_column_default table_name, :active, from: nil, to: true unless column_defaults(table_name, :active) == true
        change_column_null table_name, :active, false if columns(table_name).find { |c| c.name == 'active' }&.null
      end
    end
  end

  private

  def column_defaults(table, column)
    connection.columns(table).find { |c| c.name == column.to_s }&.default
  end

  def columns(table)
    connection.columns(table)
  end
end