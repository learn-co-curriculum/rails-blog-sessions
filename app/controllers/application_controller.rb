class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user, :user_signed_in?

  def current_user
    @current_user ||= session[:user_id] && User.find_by_id(session[:user_id])
  end

  def user_signed_in?
    session[:user_id] ? true:false
  end

  def authorize
    !user_signed_in?
  end
end
