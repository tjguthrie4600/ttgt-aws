class UsersController < ApplicationController

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
    @user = User.new(params[:user].merge(:weightPoints => 0))
    if @user.save
      # Handle a successful save
      flash[:success] = "Welcome to the AWS Web Interface!"
      sign_in @user
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
    User.find(params[:id]).destroy
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
end
