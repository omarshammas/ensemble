class Iteration < ActiveRecord::Base
  attr_accessible :finished, :task_id
  
  belongs_to :task
  has_many :iterations
end
