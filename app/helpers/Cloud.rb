#! /usr/bin/ruby                                                                                                                           

require 'aws-sdk'
 
class Cloud

  # Constructor, sets up instance of EC2 based on configuration file
  def initialize(config)
    AWS.config(YAML.load(File.read(config)))
    @ec2 = AWS::EC2.new()
  end

  # Gets a list of instances
  def getInstances()
    hash = @ec2.instances.inject({}) { |m, i| m[i.id] = ""; m}
    return hash.keys
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

  # Gets information for a single instance given an ID
  def getInfo(id)
    instance = @ec2.instances[id]
    result = "#{instance.status}:#{instance.ip_address}:#{instance.instance_type}:#{instance.image_id}"
    return result
  end

  # Returns an the ip of an instance given an ID
  def getIP(id)
    instance = @ec2.instances[id]
    result = instance.ip_address
    return result
  end

  # Returns the status of all AWS instances
  def getInstanceStatus()
    return @ec2.instances.inject({}) { |m, i| m[i.id] = i.status; m }
  end

  # Returns the ip of all AWS instances
  def getInstanceIP()
    return @ec2.instances.inject({}) { |m, i| m[i.id] = i.ip_address; m }
  end

  # Returns the ip of all AWS instances
  def getInstanceType()
    return @ec2.instances.inject({}) { |m, i| m[i.id] = i.instance_type; m }
  end

  # Returns the ip of all AWS instances
  def getInstanceImage()
    return @ec2.instances.inject({}) { |m, i| m[i.id] = i.image_id; m }
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
