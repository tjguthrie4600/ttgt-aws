class SwitchWeightToUsers < ActiveRecord::Migration
  def change
    add_column :users, :weightPoints, :integer 
    remove_column :instances, :weightPoints
  end
end
