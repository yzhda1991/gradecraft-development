require_relative "score_recalculator_job"

# Does not inherit from ResqueJob::Base since no need to retry on failure
# An exception will likely be fatal and unrecoverable
class QueueScoreRecalculatorJob
  LAST_UPDATED_RANGE = 24.hours.ago..Time.now

  @queue = :nightly_score_recalculator

  def self.perform
    # call recalculate once per unique student_id, course_id combination
    unique_grades = (updated_grades.pluck(:student_id, :course_id) + updated_earned_badges.pluck(:student_id, :course_id)).uniq
    unique_grades.each { |student_id, course_id| ScoreRecalculatorJob.new(user_id: student_id, course_id: course_id).enqueue }
  end

  private

  def self.updated_grades
    Grade.where student_visible: true, updated_at: LAST_UPDATED_RANGE
  end

  def self.updated_earned_badges
    EarnedBadge.student_visible.where updated_at: LAST_UPDATED_RANGE
  end
end
