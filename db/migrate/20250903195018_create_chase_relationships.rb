class CreateChaseRelationships < ActiveRecord::Migration[8.0]
  def change
    create_table :chase_relationships, id: :uuid do |t|
      t.references :pursuer, null: false, foreign_key: { to_table: :vehicles }, type: :uuid
      t.references :evader, null: false, foreign_key: { to_table: :vehicles }, type: :uuid
      t.references :fight, null: false, foreign_key: true, type: :uuid
      t.string :position, null: false, default: 'far'
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    # Add indexes for performance
    add_index :chase_relationships, :fight_id, where: "active = true" unless index_exists?(:chase_relationships, :fight_id)
    add_index :chase_relationships, :pursuer_id, where: "active = true" unless index_exists?(:chase_relationships, :pursuer_id)
    add_index :chase_relationships, :evader_id, where: "active = true" unless index_exists?(:chase_relationships, :evader_id)
    
    # Add constraint to ensure pursuer and evader are different
    execute <<-SQL
      ALTER TABLE chase_relationships 
      ADD CONSTRAINT different_vehicles CHECK (pursuer_id != evader_id);
      
      ALTER TABLE chase_relationships
      ADD CONSTRAINT position_values CHECK (position IN ('near', 'far'));
    SQL
    
    # Add unique index for active relationships
    add_index :chase_relationships, [:pursuer_id, :evader_id, :fight_id], 
              unique: true, 
              where: "active = true",
              name: 'unique_active_relationship'
  end
end
