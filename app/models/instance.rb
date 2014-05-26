class Instance < ActiveRecord::Base
  # IMAGES = [Amazon2013.03.1, RHEL6.5, SUSEServer11, UbuntuServer14.04] 
  IMAGES = ['ami-043a5034', 'ami-aa8bfe9a', 'ami-d8b429e8', 'ami-6ac2a85a']
  TYPES = ['t1.micro']
  attr_accessible :name, :image, :instanceType

  belongs_to :user

  VAILD_IMAGE_REGEX = /^ami-/i

  validates :image, presence: true, format: { with: VAILD_IMAGE_REGEX }
  validates :instanceType, presence: true
  validates :name, presence: true, length: {maximum: 50}

  default_scope order: 'instances.created_at DESC'
end
