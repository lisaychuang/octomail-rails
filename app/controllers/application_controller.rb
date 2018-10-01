require "octokit"
require "pry"

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user
  helper_method :user_signed_in?
  helper_method :correct_user?

  def notifications
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    @client = Octokit::Client.new(:access_token => @current_user.token)
    @json = @client.notifications

    respond_to do |format|
      format.json {
        render json: @json.map{ |item| item.to_hash }.to_json , status: 200
      }
    end

  end

  private

  def current_user
    begin
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    rescue Exception => e
      nil
    end
  end

  def user_signed_in?
    return true if current_user
  end

  def correct_user?
    @user = User.find(params[:id])
    unless current_user == @user
      redirect_to root_url, :alert => "Access denied."
    end
  end

  def authenticate_user!

    puts current_user
    if !current_user
      puts ">>> NO CURRENT USER"
      redirect_to root_url, :alert => "You need to sign in for access to this page."
    else 
      puts ">>> FOUND CURRENT USER"
    end
  end

end
