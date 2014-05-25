class ChangeColuumType < ActiveRecord::Migration
  
  def change
    rename_column :instances, :type, :instanceType
  end

  def up
  end

  def down
  end
end
