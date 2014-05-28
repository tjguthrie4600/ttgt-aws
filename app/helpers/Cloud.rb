#! /usr/bin/ruby                                                                                                                           

require 'aws-sdk'
 
class Cloud

  # Constructor, sets up instance of EC2 based on configuration file
  def initialize(config)
    AWS.config(YAML.load(File.read(config)))
    @ec2 = AWS::EC2.new()
  end

  # Start an instance
  def startInstance(id)
    instance = @ec2.instances[id]
    instance.start()
  end

  # Stop an instance
  def stopInstance(id)
    instance = @ec2.instances[id]
    instance.stop()
  end

  # Returns an the ip of an instance given an ID
  def getIP(id)
    instance = @ec2.instances[id]
    result = instance.ip_address
    return result
  end

  # Returns the status of an AWS instances
  def getStatus(id)
    instance = @ec2.instances[id]
    result = instance.status
    return result
  end

  # Creates an AWS instance
  def createInstance(image,type,owner)
    instance = @ec2.instances.create(
      :image_id => image,
      :instance_type => type,
      :key_name => owner)
    return instance
  end

  # Terminates an AWS instance given an instance ID
  def terminateInstance(id)
    instance = @ec2.instances[id]
    response = ""
    if instance.exists?
      instance.terminate()
      response = "Instance is terminating"
    else
      response = "Instance does not exist"
    end
    return response
  end
    
end 
