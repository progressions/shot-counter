class AddJunctureReferenceToParty < ActiveRecord::Migration[8.0]
  def change
    add_reference :parties, :juncture, type: :uuid, foreign_key: { to_table: :junctures }

    add_column :parties, :active, :boolean, default: true, null: false
  end
end
