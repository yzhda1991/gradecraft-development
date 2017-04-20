feature "editing an assignment type", focus: true do
  context "as a professor" do
    let(:course) { build :course, assignment_term: "Assignment"}
    let!(:course_membership) { create :course_membership, :professor, user: professor, course: course }
    let(:professor) { create :user }
    let!(:assignment_type) { create :assignment_type, name: "Assignment Type Name", course: course }

    before(:each) do
      login_as professor
      visit edit_assignment_type_path(assignment_type)
    end

    scenario "successfully" do
      within(".pageContent") do
        fill_in "Name", with: "Edited Assignment Type Name"
        click_button "Update Assignment type"
      end

      expect(page).to have_notification_message("success", "Assignment Type Edited Assignment Type Name successfully updated")
    end
  end
end
