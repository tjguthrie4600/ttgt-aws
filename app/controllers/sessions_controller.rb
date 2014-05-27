class SessionsController < ApplicationController

  def new
  end

  def create
    
    # Find the user
    user = User.find_by_email(params[:session][:email])

    # Sign in the user
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_back_or user

    # Authentication failed
    else
      flash.now[:error] = 'Invaild email/password combination'
      render 'new'
    end
  end

  # Destroys a users session
  def destroy
    sign_out
    redirect_to root_path
  end

end
