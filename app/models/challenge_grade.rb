class ChallengeGrade < ActiveRecord::Base

  attr_accessible :name, :score, :challenge_id, :text_feedback, :status, :team_id, :final_score, :status, :team, :challenge

  belongs_to :course
  belongs_to :challenge
  belongs_to :team, autosave: true
  belongs_to :submission # Optional
  belongs_to :task # Optional

  after_save :cache_team_score

  validates_presence_of :team, :challenge

  delegate :name, :description, :due_at, :point_total, to: :challenge

  # @mz todo: add specs
  scope :student_visible, -> { joins(:challenge).where(student_visible_sql) }

  # TODO: Need to bring this in and resolve dup challenge grades in production
  # validates :challenge_id, uniqueness: {scope: :team_id}

  # @mz todo: add specs
  def recalculate_student_and_team_scores
    team.update_revised_team_score
    if team.course.add_team_score_to_student?
      team.recalculate_student_scores
    end
  end

  def score
    super.presence || nil
  end

  def cache_team_score
    team.save!
  end

  def is_graded?
    status == "Graded"
  end

  def is_released?
    status == "Released"
  end

  def is_student_visible?
    is_released? || (is_graded? && !challenge.release_necessary)
  end

  private

  def self.student_visible_sql
    ["status = 'Released' OR (status = 'Graded' AND challenges.release_necessary = ?)", false]
  end
end
