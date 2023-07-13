class AddMookReferenceToShot < ActiveRecord::Migration[7.0]
  def change
    add_reference :shots, :mook, null: true, foreign_key: true, type: :uuid
  end
end
