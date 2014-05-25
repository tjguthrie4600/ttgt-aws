class CreateInstances < ActiveRecord::Migration
  def change
    create_table :instances do |t|
      t.string :status
      t.string :type
      t.string :image
      t.string :ip
      t.integer :user_id

      t.timestamps
    end
    add_index :instances, [:user_id, :created_at]
  end
end
