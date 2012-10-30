class User < ActiveRecord::Base
  attr_accessible :access_key_id, :secret_access_key
end
