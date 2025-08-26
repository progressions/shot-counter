class MigrateSecretToActive < ActiveRecord::Migration[8.0]
  def up
    # Simply ensure all NULL active values are set to true
    # We're not migrating secret fields - just ignoring them
    %w[campaigns characters factions fights parties sites vehicles junctures schticks weapons].each do |table_name|
      if table_exists?(table_name) && column_exists?(table_name, :active)
        execute <<-SQL
          UPDATE #{table_name}
          SET active = true
          WHERE active IS NULL
        SQL
        puts "Set active=true for any NULL values in #{table_name}"
      end
    end
  end
  
  def down
    # Nothing to reverse - we're just setting NULL values to true
  end
end