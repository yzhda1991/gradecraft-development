feature "editing an assignment" do
  context "as a professor" do
    let(:course) { build :course, assignment_term: "Assignment"}
    let!(:course_membership) { create :course_membership, :professor, user: professor, course: course }
    let(:professor) { create :user }
    let!(:assignment) { create :assignment, name: "Assignment Name", course: course }
    let!(:assignment_with_submission) { create :assignment, name: "Assignment With Submission", course: course, grade_scope: "Individual" }
    let!(:student)  { create(:course_membership, :student, course: course).user }
    let!(:submission) { create(:submission, assignment: assignment_with_submission, student: student, course: course) }

    before(:each) do
      login_as professor
      visit edit_assignment_path(assignment)
    end

    scenario "successfully" do
      within(".pageContent") do
        fill_in "Name", with: "Edited Assignment Name"
        click_button "Update Assignment"
      end

      expect(page).to have_notification_message("notice", "Assignment Edited Assignment Name successfully updated")
    end

    scenario "cannot change grade scope" do
      visit edit_assignment_path(assignment_with_submission)

      expect(page).to have_selector(:option, "Individual", disabled: true)
      expect(page).to have_selector(:option, "Group", disabled: true)
    end
  end
end
