class Instance < ActiveRecord::Base
  attr_accessible :name

  belongs_to :user

  validates :user_id, presence: true
  validates :image, presence: true
  validates :ip, presence: true
  validates :status, presence: true
  validates :type, presence: true
  validates :instance_id, presence: true
  validates :name, presence: true, length: {maximum: 50}

  default_scope order: 'microposts.created_at DESC'
end
