describe Services::Actions::DestroysGroupMemberships do
  let(:course) { membership.course }
  let(:membership) { create :course_membership, :student }
  let(:student) { membership.user }

  it "expects the membership to find the group memberships to destroy" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "destroys the group memberships" do
    another_group_membership = create :group_membership, student: student
    course_group_membership = create :group_membership, student: student,
      group: create(:group, course: course)
    described_class.execute membership: membership
    expect(GroupMembership.where(student_id: student.id)).to \
      eq [another_group_membership]
  end
end
