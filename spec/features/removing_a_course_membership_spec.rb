feature "removing a course membership" do
  context "as an administrator" do
    let!(:admin_course_membership) { create :course_membership, :admin, course: course, user: admin }
    let(:admin) { create :user }
    let(:course) { build :course }

    before(:each) { login_as admin }

    context "by editing a student" do
      let!(:grade) { create :grade, student: student, course: course }
      let(:student) { create :user }
      let!(:student_course_membership) { create :course_membership, :student, course: course, user: student }

      before(:each) { visit edit_user_path(student) }

      scenario "successfully" do
        EditUserPage.new(student).submit(courses: [course])
        expect(current_path).to eq user_path(student)

        expect(student.reload.course_memberships).to be_empty
        expect(student.grades).to be_empty
      end
    end
  end
end
