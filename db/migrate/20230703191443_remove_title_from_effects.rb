class RemoveTitleFromEffects < ActiveRecord::Migration[7.0]
  def change
    Effect.all.each do |effect|
      effect.update!(name: effect.title)
    end

    remove_column :effects, :title, :string
  end
end
