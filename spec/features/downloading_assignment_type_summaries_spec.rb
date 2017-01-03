require "rails_spec_helper"

feature "downloading assignment type summary file" do
  context "as a professor" do
    let(:course) { create :course }
    let!(:course_membership) { create :course_membership, :professor, user: professor, course: course }
    let(:professor) { create :user }

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "successfully" do

      @assignment_type = create(:assignment_type, course: course)

      within(".sidebar-container") do
        click_link "Course Data Exports"
      end

      within(".pageContent") do
        click_link "Assignment Type Summaries"
      end

      expect(page.response_headers["Content-Type"]).to eq("text/csv")

      expect(page).to have_content "First Name,Last Name,Email,Username,Team"
    end
  end
end
