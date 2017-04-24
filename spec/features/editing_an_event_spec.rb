feature "editing an event" do
  context "as a professor" do
    let(:course) { build :course}
    let!(:course_membership) { create :course_membership, :professor, user: professor, course: course }
    let(:professor) { create :user }
    let!(:event) { create :event, course: course, name: "Event Name", due_at: Date.today }

    before(:each) do
      login_as professor
      visit edit_event_path(event.id)
    end

    scenario "successfully" do
      within(".pageContent") do
        fill_in "Name", with: "Edited Event Name"
        click_button "Update Event"
      end

      expect(page).to have_notification_message("notice", "Event Edited Event Name was successfully updated")
    end
  end
end
