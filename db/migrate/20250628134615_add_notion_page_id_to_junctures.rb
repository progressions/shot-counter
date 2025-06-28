class AddNotionPageIdToJunctures < ActiveRecord::Migration[8.0]
  def change
    add_column :junctures, :notion_page_id, :uuid
  end
end
