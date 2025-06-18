class AddDiscordFieldsToFights < ActiveRecord::Migration[8.0]
  def change
    add_column :fights, :server_id, :bigint
    add_column :fights, :fight_message_id, :string
  end
end
