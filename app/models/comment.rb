class Comment < ActiveRecord::Base
  attr_accessible :body, :task_id, :iteration_id, :commentable_id, :commentable_type
  
  belongs_to :task
  belongs_to :iteration
  belongs_to :commentable, polymorphic: true
end
