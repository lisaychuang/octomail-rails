require "pry"

class SessionsController < ApplicationController
  def new
    redirect_to "/auth/github"
  end

  def create
    auth = request.env["omniauth.auth"]

    # Attempt to get a user from the DB, with a uid matching what we got from github
    existing_user = User.where(:provider => auth['provider'],
                      :uid => auth['uid'].to_s).first

    # If the user exists, update it with any useful info we got from github
    if existing_user
      existing_user.update_omniauth_info(auth)
    else
      redirect_to '/auth/failure'
    end

    # If existing_user is not defined (i.e., first login), create a new user from github info
    user = existing_user || User.create_with_omniauth(auth)

    reset_session
    session[:user_id] = user.id
    flash[:notice] = "You have signed in!"
    redirect_to "https://gitmailz.herokuapp.com/account"
  end

  def destroy
    reset_session
    flash[:notice] = "You have signed out!"
    redirect_to root_url
  end

  def failure
    puts ">>>> FAILURE <<<<"
    flash[:error] = "Authentication error, please try to login again"
    redirect_to root_url
  end
end
