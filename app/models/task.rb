class Task < ActiveRecord::Base
  attr_accessible :user_id
  
  belongs_to :user
  has_many :comments
  has_many :suggestions
  
end
