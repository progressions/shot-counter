class AddChannelIdToFight < ActiveRecord::Migration[8.0]
  def change
    add_column :fights, :channel_id, :bigint
  end
end
