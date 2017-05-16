feature "reviewing a group" do
  context "as a professor" do
    let(:course) { build :course }
    let(:professor) { create(:course_membership, :professor, course: course).user }
    let!(:group) { create :group, course: course, name: "Group!", approved: "Pending" }

    before(:each) do
      login_as professor
      visit groups_path
    end

    scenario "successfully" do
      within(".pageContent") do
        click_link "Review Group"
      end

      expect(current_path).to eq edit_group_path(group)

      within(".pageContent") do
        select "Approved", from: "group_approved"
        click_button "Update Group"
      end

      expect(page).to have_notification_message("notice", "Your group was successfully updated.")
    end
  end
end
