describe GroupMembership do
  describe ".for_course" do
    it "returns all the group memberships for a specific course" do
      course = create(:course)
      course_group_membership = create(:group_membership,
                                      group: create(:group, course: course))
      another_group_membership = create(:group_membership)
      results = GroupMembership.for_course(course)
      expect(results).to_not include [another_group_membership]
    end
  end

  describe ".for_student" do
    it "returns all the group memberships for a specific student" do
      student = create(:user)
      student_group_membership = create(:group_membership, student: student)
      another_group_membership = create(:group_membership)
      results = GroupMembership.for_student(student)
      expect(results).to eq [student_group_membership]
    end
  end
end
