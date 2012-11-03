class Comment < ActiveRecord::Base
  attr_accessible :body, :iteration_id, :task_id, :user_id
  
  belongs_to :task
  belongs_to :user
  belongs_to :iteration
  
end
