class Preference < ActiveRecord::Base
  attr_accessible :body, :task_id, :turk_id
end
