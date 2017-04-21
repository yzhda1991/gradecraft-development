feature "editing a course's basic settings" do
  context "as a professor" do
    let(:course) { build :course, name: "Course Name"}
    let!(:course_membership) { create :course_membership, :professor, user: professor, course: course }
    let(:professor) { create :user }

    before(:each) do
      login_as professor
      visit edit_course_path(course.id)
    end

    scenario "successfully" do
      within(".pageContent") do
        fill_in "Course Title", with: "New Course Name"
        click_button "Save Settings"
      end

      expect(current_path).to eq edit_course_path(course.id)
      expect(page).to have_notification_message("notice", "Course New Course Name successfully updated")
    end
  end
end
