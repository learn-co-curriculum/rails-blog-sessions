class SessionsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :build_session, only: :create

  def new
    @session = UserSessionAuthenticator.new
  end

  def create
    if @session.save
      session[:user_id] = @session.user_id
      redirect_to root_path, notice: "Welcome back!"
    else
      flash.now.alert = "Invalid email or password"
      render :new
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "You have been logged out."
  end

  private

  def session_params
    params.require(:user_session_authenticator).permit(:email, :password)
  end

  def build_session
    @session ||= ::UserSessionAuthenticator.new(session_params)
  end
end
