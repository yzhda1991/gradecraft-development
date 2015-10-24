class ChallengeGrade < ActiveRecord::Base

  attr_accessible :name, :rank, :score, :challenge_id, :text_feedback, :status, :team_id, :final_score, :status, :team, :challenge

  attr_accessor :graded_points

  belongs_to :course
  belongs_to :challenge
  belongs_to :team, :autosave => true
  belongs_to :submission # Optional
  belongs_to :task # Optional

  after_save :cache_team_score

  validates_presence_of :team, :challenge

  delegate :name, :description, :due_at, :point_total, :to => :challenge

  #TODO: Need to bring this in and resolve dup challenge grades in production
  #validates :challenge_id, :uniqueness => {:scope => :team_id}
  
  # @mz todo: add specs
  def recalculate_team_scores
    team.recalculate_student_scores
  end

  def score
    super.presence || 0
  end

  def cache_team_score
    team.save!
  end

  def is_graded?
    status == 'Graded'
  end

  def in_progress?
    status == 'In Progress'
  end

  def is_released?
    status == 'Released'
  end

  def is_student_visible?
    is_released? || (is_graded? && ! challenge.release_necessary)
  end
end
