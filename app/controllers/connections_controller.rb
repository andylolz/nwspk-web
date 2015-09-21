class ConnectionsController < ApplicationController
  before_filter :authenticate_user!

  def create
    auth = request.env['omniauth.auth']
    connection = Connection.find_or_create_by(provider: auth['provider'], uid: auth['uid'])

    connection.access_token = auth['credentials']['token']
    connection.secret       = auth['credentials']['secret']
    connection.expires_at   = auth['credentials']['expires_at']
    connection.profile_url  = auth['info']['urls'][auth['provider'].capitalize]
    connection.username     = auth['info']['nickname'] || auth['info']['name']
    connection.user         = current_user
    connection.save!

    # Immediately check for friends
    begin
      service = CheckFriendsService.new
      service.call(current_user)
    rescue Twitter::Error::TooManyRequests => e
    end

    redirect_to redirect_path, notice: 'Successfully connected account'
  end

  def destroy
    connection = Connection.find(params[:id])

    service = RemoveConnectionService.new
    service.call(connection)

    redirect_to dashboard_path, notice: 'Successfully disconnected account'
  end

  def failure
    redirect_to redirect_path, alert: 'There was a problem authenticating you'
  end

  def check_friends
    service = CheckFriendsService.new
    service.call(current_user)

    redirect_to dashboard_path, notice: 'Checked your friends, here are the results'
  rescue Koala::Facebook::AuthenticationError => e
    redirect_to '/auth/facebook'
  rescue Twitter::Error::Unauthorized => e
    redirect_to '/auth/twitter'
  rescue Twitter::Error::TooManyRequests => e
    redirect_to dashboard_path, alert: 'Failed to check friends, Twitter access is currently rate limited'
  end

  private

  def redirect_path
    if current_user.subscription.try(:needs_checkout?)
      checkout_subscription_path
    else
      dashboard_path
    end
  end
end
