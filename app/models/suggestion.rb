class Suggestion < ActiveRecord::Base
  attr_accessible :acceptance_status, :body, :interation_id, :task_id, :user_id, :vote_count, :vote_status
end
