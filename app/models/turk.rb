class Turk < ActiveRecord::Base
  before_create :set_code
  attr_accessible :code

  has_many :comments, as: :commentable
  has_many :suggestions, as: :suggestable

  def set_code
  	self.code = SecureRandom.base64(12)
  end
end
