class AddSshKeysWeightPointsToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :sshKeys, :string
    add_column :instances, :weightPoints, :integer
  end
end
