require_relative "challenge_grade_proctor/base"
require_relative "challenge_grade_proctor/viewable"
require_relative "challenge_grade_proctor/updatable"

# determines what sort of CRUD operations can be performed
# on a `Grade` resource
class ChallengeGradeProctor
  include Viewable

  attr_reader :challenge_grade

  def initialize(challenge_grade)
    @challenge_grade = challenge_grade
  end

  def destroyable?(options={})
    updatable? options
  end
end
