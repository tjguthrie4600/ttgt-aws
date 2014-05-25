class Instance < ActiveRecord::Base
  attr_accessible :name, :user_id, :image, :ip, :instanceType, :instance_id

  belongs_to :user

  validates :user_id, presence: true
  validates :image, presence: true
  validates :ip, presence: true
  validates :instanceType, presence: true
  validates :instance_id, presence: true
  validates :name, presence: true, length: {maximum: 50}

  default_scope order: 'instances.created_at DESC'
end
