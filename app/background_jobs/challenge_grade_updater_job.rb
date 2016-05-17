class ChallengeGradeUpdaterJob < ResqueJob::Base
  @queue = :challenge_grade_updater
  @performer_class = ChallengeGradeUpdatePerformer
end
