class Vote < ActiveRecord::Base
  attr_accessible :suggestion_id, :user_id
  
  belongs_to :suggestion
  belongs_to :user
end
