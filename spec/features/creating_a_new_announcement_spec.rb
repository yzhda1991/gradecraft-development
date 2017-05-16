feature "creating a new announcement" do
  context "as a professor" do
    let!(:course_membership) { create :course_membership, :professor, user: professor }
    let(:professor) { create :user }

    before(:each) do
      login_as professor
      visit announcements_path
    end

    scenario "unsuccessfully with just a title" do
      within(".context_menu") do
        click_link "New Announcement"
      end

      expect(current_path).to eq new_announcement_path

      within(".pageContent") do
        fill_in "announcement_title", with: "No Exam on Thursday"
        click_button "Send Announcement"
      end

      expect(current_path).to eq announcements_path
      expect(page).to have_content("Body")
    end
  end
end
