class PathDevice < ApplicationRecord
  belongs_to :path
  belongs_to :web_push_subscription
end
