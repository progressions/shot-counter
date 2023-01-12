class AddUserToEffect < ActiveRecord::Migration[7.0]
  def change
    add_reference :effects, :user, type: :uuid, null: true, foreign_key: true
  end
end
