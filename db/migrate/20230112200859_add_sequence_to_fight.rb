class AddSequenceToFight < ActiveRecord::Migration[7.0]
  def change
    add_column :fights, :sequence, :integer, null: false, default: 1
  end
end
