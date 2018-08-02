class Provider < ApplicationRecord
  belongs_to :providee, polymorphic: true

  validates_associated :providee
  validates_presence_of :name, :consumer_key, :consumer_secret
  validates :consumer_secret, confirmation: true
  validates :consumer_secret_confirmation, presence: true, if: :consumer_secret, on: :update

  def self.for_course(course)
    return nil if course.institution.nil?
    course.institution.providers.try(:first)
  end
end
