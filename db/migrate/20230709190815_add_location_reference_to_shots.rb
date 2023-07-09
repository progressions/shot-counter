class AddLocationReferenceToShots < ActiveRecord::Migration[7.0]
  def change
    add_reference :shots, :location, null: true, foreign_key: true, type: :uuid
  end
end
