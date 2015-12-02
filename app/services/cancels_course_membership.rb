require "light-service"
require_relative "cancels_course_membership/destroys_assignment_weights"
require_relative "cancels_course_membership/destroys_earned_badges"
require_relative "cancels_course_membership/destroys_earned_challenges"
require_relative "cancels_course_membership/destroys_grades"
require_relative "cancels_course_membership/destroys_group_memberships"
require_relative "cancels_course_membership/destroys_membership"
require_relative "cancels_course_membership/destroys_submissions"
require_relative "cancels_course_membership/destroys_team_memberships"

module Services
  class CancelsCourseMembership
    extend LightService::Organizer

    def self.for_student(membership)
      with(membership: membership).reduce(
        Actions::DestroysMembership,
        Actions::DestroysSubmissions,
        Actions::DestroysGrades,
        Actions::DestroysAssignmentWeights,
        Actions::DestroysEarnedBadges,
        Actions::DestroysEarnedChallenges,
        Actions::DestroysGroupMemberships,
        Actions::DestroysTeamMemberships,
        Actions::DestroysAnnouncementStates,
        Actions::DestroysFlaggedUsers
      )
    end
  end
end

class CancelsCourseMembership
  def self.for_student(membership)
    deletes_membership(membership)
      .removes_submissions(membership)
      .removes_grades(membership)
      .removes_rubric_grades(membership)
      .removes_assignment_weights(membership)
      .removes_earned_badges(membership)
      .removes_predicted_earned_badges(membership)
      .removes_predicted_earned_challenges(membership)
      .removes_group_memberships(membership)
      .removes_team_memberships(membership)
      .removes_announcement_states(membership)
      .removes_flagged_users(membership)
  end

  private

  def self.removes_announcement_states(membership)
    AnnouncementState.for_course(membership.course)
      .for_user(membership.user)
      .destroy_all
    self
  end

  def self.removes_flagged_users(membership)
    FlaggedUser.for_course(membership.course)
      .for_flagged(membership.user)
      .destroy_all
    self
  end
end
