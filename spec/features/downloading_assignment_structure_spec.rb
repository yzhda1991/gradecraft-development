feature "downloading assignment structure file" do
  context "as a professor" do
    let!(:course_membership) { create :course_membership, :professor, user: professor }
    let(:professor) { create :user }

    before(:each) do
      login_as professor
      visit downloads_path
    end

    scenario "successfully" do
      within(".pageContent") do
        click_link "Assignment Structure"
      end

      expect(page.response_headers["Content-Type"]).to eq("text/csv")
      expect(page).to have_content "Name,Assignment Type,Point Total,Description,Purpose,Open At,Due At,Accepts Submissions,Accept Until,Required,Assignment Id,Created At,Submissions Count,Grades Count,Learning Objectives"
    end
  end
end
