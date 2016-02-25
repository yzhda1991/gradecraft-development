require "rails_spec_helper"

feature "downloading assignment type summary file" do
  context "as a professor" do
    let(:course) { create :course }
    let!(:course_membership) { create :professor_course_membership, user: professor, course: course }
    let(:professor) { create :user }

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "successfully" do

      @assignment_type = create(:assignment_type, course: course)

      within(".sidebar-container") do
        click_link "assignment type Summaries"
      end

      expect(page.response_headers["Content-Type"]).to eq("application/octet-stream")

      expect(page).to have_content "First Name,Last Name,Email,Username,Team"
    end
  end
end
