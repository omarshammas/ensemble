class Iteration < ActiveRecord::Base
  attr_accessible :state, :task_id
  
  belongs_to :task
end
