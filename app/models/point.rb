class Point < ActiveRecord::Base
  attr_accessible :body, :isPro, :suggestion_id, :turk_id

  belongs_to :suggestion
  belongs_to :turk
end
