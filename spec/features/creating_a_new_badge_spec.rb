require "rails_spec_helper"

feature "creating a new badge" do
  context "as a professor" do
    let(:course) { build :course, has_badges: true}
    let!(:course_membership) { create :course_membership, :professor, user: professor, course: course }
    let(:professor) { create :user }

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "successfully" do
      within(".sidebar-container") do
        click_link "Badges"
      end

      within(".context_menu") do
        click_link "New Badge"
      end

      expect(current_path).to eq new_badge_path

      within(".pageContent") do
        fill_in "Name", with: "New Badge Name"
        click_button "Create Badge"
      end

      expect(page).to have_notification_message("notice", "New Badge Name Badge successfully created")
    end
  end
end
