class User < ActiveRecord::Base
  attr_accessible :email, :phone_number, :access_key_id, :secret_access_key, :password, :password_confirmation
  has_secure_password

  before_save { |user| user.email = email.downcase }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true
  
  has_many :tasks
  has_many :comments, as: :commentable
  has_many :suggestions, as: :suggestable

  def send_message msg
    account_sid = ENV['TWILIO_ACCOUNT_SSID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    @client = Twilio::REST::Client.new account_sid, auth_token
    @client.account.sms.messages.create(
      from: ENV['TWILIO_NUMBER'],
      to: self.phone_number,
      body: msg
    )
  end
end
