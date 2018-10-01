require 'pry'

class SessionsController < ApplicationController

  def new
    redirect_to '/auth/github'
  end

  def create
    auth = request.env["omniauth.auth"]

    # Attempt to get a user from the DB, with a uid matching what we got from github
    existing_user = User.where(:provider => auth['provider'],
                      :uid => auth['uid'].to_s).first

    # If the user exists, update it with any useful info we got from github
    existing_user.update_omniauth_info(auth) if existing_user
    
    # If existing_user is not defined (i.e., first login), create a new user from github info
    user = existing_user || User.create_with_omniauth(auth)

    reset_session
    session[:user_id] = user.id
    redirect_to root_url, :notice => 'Signed in!'
  end

  def destroy
    reset_session
    redirect_to root_url, :notice => 'Signed out!'
  end

  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
  end

end
