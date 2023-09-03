class AddNotionPageIdToCharacter < ActiveRecord::Migration[7.0]
  def change
    add_column :characters, :notion_page_id, :uuid
  end
end
