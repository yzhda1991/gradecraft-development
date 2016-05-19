class ChallengeGrade < ActiveRecord::Base
  include GradeStatus

  attr_accessible :name, :score, :challenge_id, :text_feedback, :team_id,
    :final_score, :team, :challenge

  belongs_to :course
  belongs_to :challenge
  belongs_to :team, autosave: true

  validates_presence_of :team, :challenge

  delegate :name, :description, :due_at, :point_total, to: :challenge

  releasable_through :challenge

  validates :challenge_id, uniqueness: { scope: :team_id }

  def score
    super.presence || nil
  end

  def cache_team_scores
    team.set_challenge_grade_score
    team.set_average_score
  end
end
