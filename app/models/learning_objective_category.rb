class LearningObjectiveCategory < ActiveRecord::Base
  belongs_to :course

  has_many :learning_objectives, foreign_key: :category_id, dependent: :destroy

  validates_presence_of :course, :name
end
