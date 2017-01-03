require "light-service"
require "active_record_spec_helper"
require "./app/services/cancels_course_membership/destroys_team_memberships"

describe Services::Actions::DestroysTeamMemberships do
  let(:course) { membership.course }
  let(:membership) { create :course_membership, :student }
  let(:student) { membership.user }

  it "expects the membership to find the team memberships to destroy" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "destroys the group memberships" do
    another_team_membership = create :team_membership, student: student
    course_team_membership = create :team_membership, student: student,
      team: create(:team, course: course)
    described_class.execute membership: membership
    expect(TeamMembership.where(student_id: student.id)).to \
      eq [another_team_membership]
  end
end
