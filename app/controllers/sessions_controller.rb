class SessionsController < ApplicationController
  def create
    user = User.find_by({email: params[:email]})
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "Hello, #{current_user.name}!"
    else
      flash.now.alert = "Invalid email and password confirmation"
      render 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "logged out"
  end
end
