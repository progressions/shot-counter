class AddActionIdToFight < ActiveRecord::Migration[8.0]
  def change
    add_column :fights, :action_id, :uuid
  end
end
