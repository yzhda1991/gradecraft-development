feature "editing a group" do
  context "as a professor" do
    let(:course) { build :course }
    let(:professor) { create(:course_membership, :professor, course: course).user }
    let!(:group) { create :approved_group, course: course, name: "Group!" }

    before(:each) do
      login_as professor
      visit groups_path
    end

    scenario "successfully" do
      within(".pageContent") do
        click_link "Edit Group"
      end

      within(".pageContent") do
        fill_in "Name", with: "Less Excited Group Name"
        click_button "Update Group"
      end

      expect(page).to have_notification_message("notice", "Your group was successfully updated.")
    end
  end
end
