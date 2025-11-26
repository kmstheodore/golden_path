class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web_push_subscriptions push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper_method :vapid_public_key

  def vapid_public_key
    ENV['VAPID_PUBLIC_KEY']
  end

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
