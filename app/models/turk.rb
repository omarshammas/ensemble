class Turk < ActiveRecord::Base
  has_many :comments, as: :commentable
  has_many :suggestions, as: :suggestable
  has_many :votes
  has_many :points
end
