class RemoveStatusFromInstances < ActiveRecord::Migration
  def up
    remove_column :instances, :status
  end

#  def down
#    add_column :instances, :status, :string
#  end
end
