class AddNameInsteadOfTitle < ActiveRecord::Migration[7.0]
  def change
    add_column :character_effects, :name, :string
    add_column :schticks, :name, :string
    add_column :campaigns, :name, :string
    add_column :effects, :name, :string

    add_index :schticks, [:category, :name], unique: true
  end
end
