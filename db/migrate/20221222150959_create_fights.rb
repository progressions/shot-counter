class CreateFights < ActiveRecord::Migration[7.0]
  def change
    create_table :fights, id: :uuid do |t|
      t.string :name

      t.timestamps
    end
  end
end
