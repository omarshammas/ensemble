class Vote < ActiveRecord::Base
  attr_accessible :suggestion_id, :turk_id
  
  belongs_to :suggestion
  belongs_to :turk
end
