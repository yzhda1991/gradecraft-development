class TeamMembership < ActiveRecord::Base
  attr_accessible :team, :team_id, :student, :student_id

  belongs_to :team
  belongs_to :student, class_name: 'User'

  def team_score
    Grade
      .where(course_id: course.id)
      .where(student_id: user.id)
      .sum(&:score)
  end

  def challenge_grade_score
    ChallengeGrade
      .where(team_id: team_id)
  end
end
