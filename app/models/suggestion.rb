class Suggestion < ActiveRecord::Base
  attr_accessible :acceptance_status, :body, :iteration_id, :task_id, :user_id, :vote_count, :vote_status

  belongs_to :interation
  belongs_to :task
  belongs_to :user
  
  has_many :votes
end
