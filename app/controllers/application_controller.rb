class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_user!

  private

  def authenticate_user!
    unless user_signed_in?
      flash[:notice] = "You must be signed in."
      redirect_to login_path
    end
  end

  def user_signed_in?
    !!session[:user_id]
  end
end
