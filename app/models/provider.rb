require 'scrypt'

class Provider < ActiveRecord::Base
  before_save :encrypt_consumer_secret

  belongs_to :institution

  validates_presence_of :name, :consumer_key, :consumer_secret

  def decrypted_consumer_secret
    SCrypt::Password.new consumer_secret
  end

  private

  def encrypt_consumer_secret
    self.consumer_secret = SCrypt::Password.create consumer_secret
  end
end
