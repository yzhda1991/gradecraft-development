require 'scrypt'

class Provider < ActiveRecord::Base
  before_save :encrypt_consumer_secret

  belongs_to :providee, polymorphic: true

  validates_associated :providee
  validates_presence_of :name, :consumer_key, :consumer_secret
  validates :consumer_secret, confirmation: true
  validates :consumer_secret_confirmation, presence: true, if: :consumer_secret, on: :update

  def self.for(course)
    course.institution.providers.first
  end

  def decrypted_consumer_secret
    SCrypt::Password.new consumer_secret
  end

  private

  def encrypt_consumer_secret
    self.consumer_secret = SCrypt::Password.create consumer_secret
  end
end
