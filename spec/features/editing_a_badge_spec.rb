feature "editing a badge" do
  context "as a professor" do
    let(:course) { build :course, has_badges: true}
    let!(:course_membership) { create :course_membership, :professor, user: professor, course: course }
    let(:professor) { create :user }
    let!(:badge) { create :badge, name: "Fancy Badge", course: course}

    before(:each) do
      login_as professor
      visit edit_badge_path(badge.id)
    end

    scenario "successfully" do
      within(".pageContent") do
        fill_in "Name", with: "Edited Badge Name"
        click_button "Update Badge"
      end
      expect(page).to have_notification_message("notice", "Edited Badge Name Badge successfully updated")
    end
  end
end
