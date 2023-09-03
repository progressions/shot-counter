class AddNotionPageIdToVehicle < ActiveRecord::Migration[7.0]
  def change
    add_column :vehicles, :notion_page_id, :uuid
  end
end
