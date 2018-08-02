require "light-service"
require_relative "cancels_course_membership/destroys_announcement_states"
require_relative "cancels_course_membership/destroys_assignment_type_weights"
require_relative "cancels_course_membership/destroys_earned_badges"
require_relative "cancels_course_membership/destroys_earned_challenges"
require_relative "cancels_course_membership/destroys_flagged_users"
require_relative "cancels_course_membership/destroys_grades"
require_relative "cancels_course_membership/destroys_group_memberships"
require_relative "cancels_course_membership/destroys_membership"
require_relative "cancels_course_membership/destroys_submissions"
require_relative "cancels_course_membership/destroys_team_memberships"

module Services
  class CancelsCourseMembership
    extend LightService::Organizer

    def self.call(membership)
      with(membership: membership).reduce(
        Actions::DestroysMembership,
        Actions::DestroysSubmissions,
        Actions::DestroysGrades,
        Actions::DestroysAssignmentTypeWeights,
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
