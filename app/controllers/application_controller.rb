require "octokit"
require "pry"

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, only: []
  helper_method :current_user
  helper_method :user_signed_in?
  helper_method :correct_user?

  # Get current user info
  def user_info
    @current_user ||= User.find(session[:user_id]) if session[:user_id]

    respond_to do |format|
      name = @current_user.name
      username = @current_user.username
      format.json {
        render json: {
          :name => name,
          :username => username,
        }.to_json, status: 200
      }
    end
  end

  # Get current user's notifications
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
      add_score_url_to_notification(notification, {favRepos: @current_user.UserPreference.repos})
    end

    respond_to do |format|
      format.json {
        render json: @json.to_json, status: 200
      }
    end
  end

  # Get current user's favorite repos as a string
  def fav_repos
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    @json = @current_user.UserPreference[:search_input]

    respond_to do |format|
      format.json {
        render json: @json.to_json, status: 200
      }
    end
  end

  # Find exact repo link
  def find_repos
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    @client = Octokit::Client.new(:access_token => @current_user.token)

    # get user input from API
    user_input_string = request.params[:_json]
    input_arr = user_input_string.gsub(/\s+/, "").split(",")

    # search repos using user input
    repoids = input_arr.map do |input|
      repo = @client.repository(input)
      "#{repo.to_hash[:id]}"
    end

    # Save user search input and repos to UserPreference
    @current_user.UserPreference.search_input = user_input_string
    @current_user.UserPreference.repos = repoids.join(",")
    @current_user.UserPreference.save

    respond_to do |format|
      format.json {
        render json: repoids.to_json, status: 200
      }
    end
  end

  # Search term returns a list of 50 repos
  def search_repos
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    @client = Octokit::Client.new(:access_token => @current_user.token)

    # search repos using user query
    repos = @client.search_repositories("ember")

    @json = repos.items.map do |repo|
      nhash = repo.to_hash
      nhash
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

  #Add score attribute & value to each notification based on its "reason"
  #    notification_url attribute & value to each notification based on its "subject.type"
  def add_score_url_to_notification(notification, options)
    isFave = options[:favRepos].include?(notification.repository.id.to_s)
    nhash = notification.to_hash

    if isFave
      nhash[:score] = score_from_reason(notification[:reason]) + 100
    else
      nhash[:score] = score_from_reason(notification[:reason])
    end

    nhash[:notification_url] = transform_api_url(notification[:subject][:type], notification[:subject][:url], notification[:subject][:title], notification[:repository][:html_url])
    nhash
  end

  # define score for each type of "reason"
  # higher score = more important
  def score_from_reason(reason)
    case reason
    when "invitation"
      9
    when "mention"
      8
    when "assign"
      7
    when "team_mention"
      6
    when "manual"
      5
    when "author"
      4
    when "state_change"
      3
    when "comment"
      2
    when "subscribed"
      1
    else
      0
    end
  end

  # transform api_url for each notification's "subject.type"

  def transform_api_url(subject_type, api_url, title, html_url)
    case subject_type
    when "PullRequest"
      pull_request_url(api_url)
    when "Release"
      release_url(api_url, title)
    when "Issue"
      issue_url(api_url)
    when "RepositoryInvitation"
      invite_url(html_url)
    else
      "https://github.com/notifications"
    end
  end

  # Notification type: PULL REQUEST
  # Transform api url to html url
  def pull_request_url(api_url)
    # https://api.github.com/repos/typed-ember/ember-cli-typescript/pulls/334
    api_index = api_url.index("api")
    repos_index = api_url.index("repos")
    pulls_index = api_url.index("pulls")

    # https://github.com/typed-ember/ember-cli-typescript/pull/334
    html_url = api_url[0..api_index - 1] +
               api_url[api_index + "api.".length..repos_index - 1] +
               api_url[repos_index + "repos/".length..pulls_index + "pull".length - 1] +
               api_url[pulls_index + "pulls".length..-1]
    html_url
  end

  # Notification type: RELEASE
  # Transform api url to html url
  def release_url(api_url, title)
    # "subject": {
    #   "title": "v1.4.4",
    #   "url": "https://api.github.com/repos/typed-ember/ember-cli-typescript/releases/13191777",
    #   "latest_comment_url": "https://api.github.com/repos/typed-ember/ember-cli-typescript/releases/13191777",
    #   "type": "Release"
    # },
    api_index = api_url.index("api")
    repos_index = api_url.index("repos")
    releases_index = api_url.index("releases")

    # https://github.com/typed-ember/ember-cli-typescript/releases/tag/v1.4.4
    html_url = api_url[0..api_index - 1] +
               api_url[api_index + "api.".length..repos_index - 1] +
               api_url[repos_index + "repos/".length..releases_index + "releases".length] +
               "tag/#{title}"
    html_url
  end

  # Notification type: ISSUE
  # Transform api url to html url
  def issue_url(api_url)
    # "https://api.github.com/repos/typed-ember/ember-cli-typescript/issues/322"
    api_index = api_url.index("api")
    repos_index = api_url.index("repos")

    # https://github.com/typed-ember/ember-cli-typescript/issues/322
    html_url = api_url[0..api_index - 1] +
               api_url[api_index + "api.".length..repos_index - 1] +
               api_url[repos_index + "repos/".length..-1]
    html_url
  end

  # Notification type: REPO INVITATION
  # Transform repo url to html url
  def invite_url(html_url)
    # https://github.com/mike-north/micro-observable

    # https://github.com/mike-north/micro-observable/invitations
    invite_url = html_url + "/invitations"
    invite_url
  end
end
