class CreateMooks < ActiveRecord::Migration[7.0]
  def change
    create_table :mooks, id: :uuid do |t|
      t.integer :count
      t.string :color

      t.timestamps
    end
  end
end
