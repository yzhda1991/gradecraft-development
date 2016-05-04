module SubmissionFileAbility
  def define_submission_file_abilities(user, course)
    can :download, SubmissionFile do |submission_file|
      SubmissionFileProctor.new(submission_file)
        .downloadable?(user: user, course: course)
    end
  end
end
