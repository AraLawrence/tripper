class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

rescue_from ActiveRecord::RecordNotFound, with: :not_found 
rescue_from Exception, with: :not_found
rescue_from ActionController::RoutingError, with: :not_found

def raise_not_found
  raise ActionController::RoutingError.new("No route matches #{params[:unmatched_route]}")
end

def not_found
  respond_to do |format|
    format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
    format.xml { head :not_found }
    format.any { head :not_found }
  end
end

def error
  respond_to do |format|
    format.html { render :file => "#{Rails.root}/public/500", :layout => false, :status => :error }
    format.xml { head :not_found }
    format.any { head :not_found }
  end
end

  before_action :current_user

  def is_authenticated?
    unless current_user
      gflash :error => "Need to logged in to do that action!"
      redirect_to root_path
    end
  end

  def get_js
  	@goog_js = ENV['GOOGLE_JS']
  end

  def current_user
  	@current_user ||=User.find_by_id(session[:user_id])
  end

end