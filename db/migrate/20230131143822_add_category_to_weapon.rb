class AddCategoryToWeapon < ActiveRecord::Migration[7.0]
  def change
    add_column :weapons, :category, :string, null: true
  end
end
