class Institution < ActiveRecord::Base
  has_many :courses
  has_many :providers, dependent: :destroy, as: :providee

  validates_presence_of :provider, :has_site_license
end
