class CreateImagePositions < ActiveRecord::Migration[7.0]
  def change
    create_table :image_positions, id: :uuid do |t|
      t.references :positionable, type: :uuid, polymorphic: true, null: false
      t.string "context", null: false
      t.float "x_position", default: 0.0
      t.float "y_position", default: 0.0
      t.jsonb "style_overrides", default: {}
      t.timestamps
    end

    add_index :image_positions, [:positionable_type, :positionable_id, :context], unique: true, name: "index_image_positions_on_positionable_and_context"
  end
end
