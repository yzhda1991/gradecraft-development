class Institution < ActiveRecord::Base
  has_many :courses
  has_many :providers, dependent: :destroy, as: :providee

  validates :name, presence: true, uniqueness: true

  accepts_nested_attributes_for :providers
end
