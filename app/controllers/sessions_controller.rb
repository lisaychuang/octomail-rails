require "pry"

class SessionsController < ApplicationController
  @@ui_host = Rails.env === "development" ? "http://localhost:4000" : "https://gitmailz.herokuapp.com"
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
    end

    # If existing_user is not defined (i.e., first login), create a new user from github info
    user = existing_user || User.create_with_omniauth(auth)

    reset_session

    # If we successfully found existing user or created a new user
    # Redirect to account info page
    if user 
      session[:user_id] = user.id
      puts "User signed in: #{user.id}"
      flash[:notice] = "You are signed in!"
      redirect_to "#{@@ui_host}/account"

    # If not, redirect to failure page and ask user to login again
    else
      redirect_to '/auth/failure'
    end
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
