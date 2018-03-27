feature "downloading final grades file" do
  context "as a professor" do
    let(:course) { build :course }
    let!(:course_membership) { create :course_membership, :professor, user: professor, course: course }
    let(:professor) { create :user }

    before(:each) do
      login_as professor
      visit downloads_path
    end

    scenario "successfully" do
      within(".pageContent") do
        click_link "Final Grades"
      end

      expect(page.response_headers["Content-Type"]).to eq("text/csv")

      expect(page).to have_content "First Name,Last Name,Email,Username,Score,Grade,Level,Team,Earned Badge #,GradeCraft ID"
    end
  end
end
