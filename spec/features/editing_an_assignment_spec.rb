feature "editing an assignment" do
  context "as a professor" do
    let(:course) { build :course, assignment_term: "Assignment"}
    let!(:course_membership) { create :course_membership, :professor, user: professor, course: course }
    let(:professor) { create :user }
    let!(:assignment) { create :assignment, name: "Assignment Name", course: course }

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
  end
end
