class AddInstanceIdToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :instance_id, :string
  end
end
