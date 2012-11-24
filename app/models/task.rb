class Task < ActiveRecord::Base
  attr_accessible :user_id, :body, :image
  
  belongs_to :user
  has_many :comments
  has_many :suggestions
  
  has_attached_file :image, :styles => {:medium => "300x300", :small => "200x200>", :thumb => "100x100>" }
  
end
