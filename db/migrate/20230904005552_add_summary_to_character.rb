class AddSummaryToCharacter < ActiveRecord::Migration[7.0]
  def change
    add_column :characters, :summary, :string
  end
end
