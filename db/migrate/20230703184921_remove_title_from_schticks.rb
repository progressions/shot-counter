class RemoveTitleFromSchticks < ActiveRecord::Migration[7.0]
  def change
    Schtick.find_each do |schtick|
      schtick.update(name: schtick.title)
    end

    remove_column :schticks, :title
  rescue StandardError
  end
end
