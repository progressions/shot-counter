class AddTaskToCharacter < ActiveRecord::Migration[7.0]
  def change
    add_column :characters, :task, :boolean
  end
end
