class CreateEffects < ActiveRecord::Migration[7.0]
  def change
    create_table :effects, id: :uuid do |t|
      t.string :title
      t.string :description

      t.timestamps
    end
  end
end
