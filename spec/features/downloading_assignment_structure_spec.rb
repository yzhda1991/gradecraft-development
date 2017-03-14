feature "downloading assignment structure file" do
  context "as a professor" do
    let!(:course_membership) { create :course_membership, :professor, user: professor }
    let(:professor) { create :user }

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "successfully" do

      within(".sidebar-container") do
        click_link "Course Data Exports"
      end

      within(".pageContent") do
        click_link "Assignment Structure"
      end

      expect(page.response_headers["Content-Type"]).to eq("text/csv")

      expect(page).to have_content "Assignment ID,Name,Point Total,Description,Open At,Due At,Accept Until"
    end
  end
end
