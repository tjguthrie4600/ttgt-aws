class ChangeColuumInstanceId < ActiveRecord::Migration

  def change
    rename_column :instances, :instance_id, :instanceID
  end
  
  def up
  end

  def down
  end
end
