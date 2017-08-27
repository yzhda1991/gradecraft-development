feature "editing submissions", focus: true do
  context "as a student" do
    let!(:submission) do
      create :submission, course: membership.course, assignment: assignment, student: student
    end

    let(:assignment) { build :assignment, accepts_submissions: true, resubmissions_allowed: true, course: membership.course }
    let(:membership) { create :course_membership, :student, user: student }
    let(:student) { create :user }

    before { login_as student }

    scenario "notification of a resubmission" do
      create :grade, student_visible: true, student: student, submission: submission,
        assignment: assignment
      visit edit_assignment_submission_path assignment, submission

      within ".pageContent" do
        expect(page).to have_content "Resubmission!"
      end
    end
  end
end
