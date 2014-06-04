class AddLockColumnToUser < ActiveRecord::Migration
  def change
    add_column :users, :lock, :boolean
  end
end
