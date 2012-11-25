class Hit < ActiveRecord::Base
  before_create :set_code
  attr_accessible :code, :h_id, :type_id, :url, :task_id

  belongs_to :task

  def set_code
  	self.code = SecureRandom.base64(12)
  end
end
