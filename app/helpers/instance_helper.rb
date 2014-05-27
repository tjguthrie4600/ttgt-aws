module InstanceHelper

require 'Cloud'


  def getStat(id)
    cloud = Cloud.new("/apps/local/ttgt-aws/conf/AWS.conf")
    cloudStatus = cloud.getStatus(id).to_s
    value = 0

    if cloudStatus == "running"
      value = 1
    elsif cloudStatus == "pending" || cloudStatus == "shutting-down" || cloudStatus == "stopping"
      value = 2
    else
      value = 3
    end

    return value
  end

end
