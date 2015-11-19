class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def is_authenticated?
    unless current_user
    	flash[:danger] = "Invalid credentials."
    	redirect_to trip_index
    end
  end

  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end
end
