class Instance < ActiveRecord::Base

  # IMAGES = [Amazon2013.03.1, RHEL6.5, SUSEServer11, UbuntuServer14.04] 
  IMAGES = ['ami-fb8e9292', 'ami-8d756fe4', 'ami-e8084981', 'ami-018c9568']
  TYPES = ['t1.micro', 'm1.small', 'm3.medium', 'm3.large', 'm3.xlarge', 'm3.2xlarge']
  KEYS = ['TT-AWS-ENG-201405', 'test-key-pair-elg-01', 'tjguthrie4600']
  
  attr_accessible :name, :image, :instanceType, :instanceID, :ip

  belongs_to :user

  VAILD_IMAGE_REGEX = /^ami-/i
  VAILD_ID_REGEX = /^i-/i

  validates :image, presence: true, format: { with: VAILD_IMAGE_REGEX }
  validates :instanceType, presence: true
  validates :name, presence: true, length: { maximum: 50 }
  validates :instanceID, format: { with: VAILD_ID_REGEX }
  validates :weightPoints, length: { maximum: 24 }
  validates :sshKeys, presence: true

  default_scope order: 'instances.created_at DESC'
end
