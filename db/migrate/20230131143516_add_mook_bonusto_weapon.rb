class AddMookBonustoWeapon < ActiveRecord::Migration[7.0]
  def change
    add_column :weapons, :mook_bonus, :integer, null: false, default: 0
  end
end
