class Suggestion < ActiveRecord::Base
  attr_accessible :acceptance_status, :body, :task_id, :iteration_id, :vote_count, :vote_status, :suggestable_id, :suggestable_type

  belongs_to :task
  belongs_to :iteration
  belongs_to :suggestable, polymorphic: true
  
  has_many :votes
end
