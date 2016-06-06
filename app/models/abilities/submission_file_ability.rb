module SubmissionFileAbility
  def define_submission_file_abilities(user)
    can :download, SubmissionFile do |submission_file|
      SubmissionFileProctor.new(submission_file).downloadable_by? user
    end
  end
end
