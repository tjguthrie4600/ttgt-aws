class InstancesController < ApplicationController

  before_filter :signed_in_user

  def new
    @instance = Instance.new
  end

  def create
    @instance = current_user.instances.build(params[:instance])
    if @instance.save
      current_user ||= User.find_by_remember_token(cookies[:remember_token])
      flash[:sucess] = "Instance Created!"
      redirect_to "/users/#{current_user.id}"
    else
      render 'new'
    end
  end

  def destroy
  end

end
