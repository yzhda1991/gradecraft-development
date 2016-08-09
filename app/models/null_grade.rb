class NullGrade

  def assignment
    NullAssignment.new
  end

  def course
    NullCourse.new
  end

  def course_id
    0
  end

  def is_released?
    false
  end

  def is_graded?
    true
  end

  def id
    0
  end

  def team_id
    0
  end

  def challenge_id
    0
  end

  def full_points
    555
  end

  def score
    nil
  end

  def excluded_from_course_score?
    false
  end

  def student_id
    0
  end

  def raw_points
    nil
  end

  def final_points
    nil
  end

  def status
    nil
  end

  def pass_fail_status
    nil
  end

  def feedback
    nil
  end

  def updated_at
    nil
  end

  def graded_at
    nil
  end

  def student
    NullStudent.new
  end

  def team
    NullTeam.new
  end

  def challenge
    NullAssignment.new
  end
end

class NullAssignment
  def submissions_have_closed?
    false
  end

  def accepts_submissions?
    false
  end

  def release_necessary?
    false
  end
end

class NullCourse
  def id
    0
  end
end
