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

    # get first 50 notifications (github paginates at 50)
    notifications = @client.notifications({all: true, per_page: 50})

    # if there are more pages, get page 2
    more_pages = @client.last_response.rels[:next]
    if more_pages
      notifications.concat more_pages.get.data
    end

    # Consider how to get more pages...
    # page_count = 0
    # while more_pages and page_count < 10
    #   notifications.concat more_pages.get.data
    #   page_count++
    #   more_pages = @client.last_response.rels[:next]
    # end

    # iterate over notifications to:
    # add score value
    # add notification_url value
    @json = notifications.map do |notification|
      add_score_url_to_notification(notification)
    end

    respond_to do |format|
      format.json {
        render json: @json.to_json, status: 200
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
