class RemoveCharacterFromSite < ActiveRecord::Migration[7.0]
  def change
    remove_reference :sites, :character, foreign_key: true, type: :uuid
  rescue StandardError
  end
end
