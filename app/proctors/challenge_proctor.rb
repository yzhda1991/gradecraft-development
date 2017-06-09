require_relative "challenge_proctor/base"
require_relative "challenge_proctor/viewable"

# determines what sort of CRUD operations can be performed
# on a `challenge` resource
class ChallengeProctor
  include Viewable

  attr_reader :challenge

  def initialize(challenge)
    @challenge = challenge
  end
end
