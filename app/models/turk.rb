class Turk < ActiveRecord::Base
  has_many :comments, as: :commentable
  has_many :suggestions, as: :suggestable
end
