class AddFactionReferenceToParty < ActiveRecord::Migration[7.0]
  def change
    add_reference :parties, :faction, null: true, foreign_key: true, type: :uuid
  end
end
