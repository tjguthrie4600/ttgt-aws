class InstancesController < ApplicationController

  require 'Cloud'
  before_filter :signed_in_user

  # New form for the instance to be created
  def new
    @instance = Instance.new
  end

  # Creates instance in AWS and in application database
  def create    

    # Find the user
    current_user ||= User.find_by_remember_token(cookies[:remember_token])
      
    # Get information from form
    image = params[:instance][:image]
    instanceType = params[:instance][:instanceType]
    sshKeys = params[:instance][:sshKeys]

    # Update weights
    success = updateWeight(current_user, instanceType, "add")

    if success
      # Create the new instance in AWS
      cloud = Cloud.new("/apps/local/ttgt-aws/conf/AWS.conf")
      cloudInstance = cloud.createInstance(image, instanceType, sshKeys)
      cloudID = cloudInstance.id
      cloudIP = nil
      
      # Wait for amazon to assign the ip address to the instance
      while cloudIP.nil?
        cloudIP = cloudInstance.ip_address
        sleep(1)
      end
    
      # Save the instance information in the database
      @instance = current_user.instances.build(params[:instance].merge(:instanceID => cloudID, :ip => cloudIP))
      if @instance.save
        flash[:success] = "Instance Created!"
        redirect_to "/users/#{current_user.id}"
      else
        render 'new'
      end
    end
  end

  def destroy
    # Find the user and insatnce
    current_user ||= User.find_by_remember_token(cookies[:remember_token])
    instance = Instance.find(params[:id])
    instanceType = instance.instanceType

    # Update weights
    updateWeight(current_user, instanceType, "subtract")

    # Destroy the instance in AWS
    cloud = Cloud.new("/apps/local/ttgt-aws/conf/AWS.conf")
    awsID = instance.instanceID
    cloud.terminateInstance(awsID)

    # Destroy the instance in the database
    instance.destroy
    session[:return_to] ||= request.referer
    flash[:success] = "Instance destroyed."
    redirect_to session.delete(:return_to)
  end

  def start
    # Get the user and instance
    instance = Instance.find(params[:id])
    current_user ||= User.find_by_remember_token(cookies[:remember_token])

    # Start the instance in the cloud
    cloud = Cloud.new("/apps/local/ttgt-aws/conf/AWS.conf")
    awsID = instance.instanceID
    cloud.startInstance(awsID)

    # Report back to user
    session[:return_to] ||= request.referer
    flash[:success] = "Instance Starting!"
    redirect_to session.delete(:return_to)
  end

  def stop
    # Get the user and instance
    instance = Instance.find(params[:id])
    current_user ||= User.find_by_remember_token(cookies[:remember_token])

    # Stop the instance in the cloud
    cloud = Cloud.new("/apps/local/ttgt-aws/conf/AWS.conf")
    awsID = instance.instanceID
    cloud.stopInstance(awsID)
    
    # Report back to user
    session[:return_to] ||= request.referer
    flash[:success] = "Instance Stopping!"
    redirect_to session.delete(:return_to)
  end

  private

  # Takes in the user and type of the instance added or subtracted  and updates the weight
  def updateWeight(user, type, function)

    success = false

    weightMapping = {'t1.micro' => 1, 'm1.small' => 2, 'm3.medium' => 4, 'm3.large' => 6, 'm3.xlarge' => 12, 'm3.2xlarge' => 24}
    currentPoints = user.weightPoints
    if function == "add"
      newPoints = currentPoints + weightMapping[type]
    else
      newPoints = currentPoints - weightMapping[type]
    end

    logger.info "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" 
    logger.info newPoints

    if newPoints < 25
      user.update_column(:weightPoints, newPoints)
      success = true
    else
      flash[:failure] = "Maximum points exceeded, destroy some instances"
      redirect_to "/users/#{current_user.id}"
      success = false
    end
    return success
  end

end
