class Comment < ActiveRecord::Base
  attr_accessible :body, :iteration_id, :task_id, :user_id
end
