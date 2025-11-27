class PathShare < ApplicationRecord
  belongs_to :path
  belongs_to :user
end