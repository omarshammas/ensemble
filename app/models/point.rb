class Point < ActiveRecord::Base
  attr_accessible :body, :isPro, :suggestion_id

  belongs_to :suggestion
end
