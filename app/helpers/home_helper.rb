require 'open-uri'

module HomeHelper
  def profile_image_url(user)
    return gravatar_url(user.email)
  end

  def gravatar_url(email)
    ["https://gravatar.com/avatar/", Digest::MD5.hexdigest(email), "?s=250&d=", URI::encode(asset_url('default-face.jpg'))].join
  end

  def social_media_url(user)
    if !user.twitter.nil?
      return user.twitter.profile_url
    elsif !user.facebook.nil?
      return user.facebook.profile_url
    else
      return graphs_full_url(focus: user.id)
    end
  end

  def goal_percent(pledge)
    ((pledge / (1000 * base_plan_rate_raw)) * 100).round(1)
  end
end
