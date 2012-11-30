class Suggestion < ActiveRecord::Base
  attr_accessible :accepted, :price, :product_name, :retailer, :body, :task_id, :iteration_id, :vote_count, :sent, :suggestable_id, :suggestable_type

  belongs_to :task
  belongs_to :iteration
  belongs_to :suggestable, polymorphic: true
  
  has_many :votes
end
