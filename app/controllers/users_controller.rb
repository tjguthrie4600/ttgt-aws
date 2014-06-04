class UsersController < ApplicationController

  require 'net/smtp'

  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy]
  before_filter :correct_user, only: [:edit, :update]
  before_filter :admin_user, only: :destroy

  # Shows a single user record
  def show
    @user = User.find(params[:id])
    @instances = @user.instances
  end

  # Form for new user record
  def new
    @user = User.new
  end

  # Create the new user record, provided from information in the form
  def create
    @user = User.new(params[:user].merge(:weightPoints => 0, :lock => true))
    if @user.save
      # Handle a successful save
      sendEmail @user
      flash[:success] = "Welcome to the AWS Web Interface! Your system administrator must manually unlock your account. A request has been sent. You will get an email when your account has been activated."
      redirect_to @user
    else
      render 'new'
    end
  end

  # Display form for existing record
  def edit
  end

  # Update a single record from form in edit
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      # Handle sucessful update
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  # Query and list all users
  def index
    @users = User.all
  end

  # Remove a user from the database
  def destroy
    user = User.find(params[:id])
    destroyInstances(user)
    user.destroy
    flash[:success] = "User destroyed."
    redirect_to users_path
  end

  private

    # Is the user signed in, if not redirect them
    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_path, notice: "Please sign in."
      end
    end

    # Authorization
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    # Authoriztion for super user
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end

    # Destroys all instances assicoated with user in AWS
    def destroyInstances(user)
      cloud = Cloud.new("/apps/local/ttgt-aws/conf/AWS.conf")
      instances = Instance.where(:user_id => user.id)
      for instance in instances
        awsID = instance.instanceID
        cloud.terminateInstance(awsID)
      end
    end

# Sends email to sysadmins for new account activation
def sendEmail(user)
  name = user.name
  email = user.email
  id = user.id
  command = 'ssh root@pv-railsma1.techtarget.com \'cd /apps/local/ttgt-aws/srv && echo "User.find(' + id.to_s + ').toggle!(:lock)" | rails console\''
  message = <<MESSAGE_END
From: AWS Application <aws@railsma1.techtarget.com>
To: SysAdmins <sysadmins@techtarget.com>
Subject: Account Request

\nName = #{name} \nEmail = #{email} \nID = #{id} \nCommand to Activate = #{command}\n 
MESSAGE_END
  Net::SMTP.start('localhost') do |smtp|
    smtp.send_message message, 'aws@railsma1.techtarget.com',
    'sysadmins@techtarget.com'
  end
end
end
