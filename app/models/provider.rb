class Provider < ActiveRecord::Base
  belongs_to :institution

  validates_presence_of :name, :consumer_key, :consumer_secret
end
