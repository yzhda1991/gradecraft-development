class Institution < ActiveRecord::Base
  has_many :courses

  validates_presence_of :name, :has_site_license
end
