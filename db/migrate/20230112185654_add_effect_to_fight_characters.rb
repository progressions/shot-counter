class AddEffectToFightCharacters < ActiveRecord::Migration[7.0]
  def change
    add_reference :fight_characters, :effect, type: :uuid, null: true
  end
end
