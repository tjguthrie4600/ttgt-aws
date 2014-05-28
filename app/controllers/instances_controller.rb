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

    # Create the new instance in AWS
    cloud = Cloud.new("/apps/local/ttgt-aws/conf/AWS.conf")
    cloudInstance = cloud.createInstance(image, instanceType, "tjguthrie4600")
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

  def destroy
    # Find the user
    current_user ||= User.find_by_remember_token(cookies[:remember_token])

    # Destroy the instance in AWS
    cloud = Cloud.new("/apps/local/ttgt-aws/conf/AWS.conf")
    instance = Instance.find(params[:id])
    awsID = instance.instanceID
    cloud.terminateInstance(awsID)

    # Destroy the instance in the database
    instance.destroy
    session[:return_to] ||= request.referer
    flash[:success] = "Instance destroyed."
    redirect_to session.delete(:return_to)
  end

  def start
    # Start the instance in the cloud
    cloud = Cloud.new("/apps/local/ttgt-aws/conf/AWS.conf")
    instance = Instance.find(params[:id])
    awsID = instance.instanceID
    cloud.startInstance(awsID)

    # Report back to user
    current_user ||= User.find_by_remember_token(cookies[:remember_token])
    session[:return_to] ||= request.referer
    flash[:success] = "Instance Starting!"
    redirect_to session.delete(:return_to)
  end

  def stop
    # Stop the instance in the cloud
    cloud = Cloud.new("/apps/local/ttgt-aws/conf/AWS.conf")
    instance = Instance.find(params[:id])
    awsID = instance.instanceID
    cloud.stopInstance(awsID)
    
    # Report back to user
    current_user ||= User.find_by_remember_token(cookies[:remember_token])
    session[:return_to] ||= request.referer
    flash[:success] = "Instance Stopping!"
    redirect_to session.delete(:return_to)
  end

end
