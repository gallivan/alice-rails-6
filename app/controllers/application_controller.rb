class ApplicationController < ActionController::Base

  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead
  # protect_from_forgery except: :sign_in

  before_action :authenticate_user!
  protect_from_forgery with: :exception
end
