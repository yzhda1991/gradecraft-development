require "spec_helper"

feature "submitting an assignment", focus: true do
  let(:password) { "p@ssword" }

  context "as a student" do
    let(:course) { create :course }
    let!(:course_membership) { create :student_course_membership, user: user, course: course }
    let(:user) { create :user, password: password }

    let(:assignment_type) {create :assignment_type, course: course, name: "Assignment Type Name"}
    let(:assignment) {create :individual_assignment_with_submissions, assignment_type: assignment_type, course: course}

    before { visit root_path }

    before(:each) do
      LoginPage.new(user).submit({ password: password })
    end

    scenario "successfully from the assignment page" do

      visit assignment_path("#{assignment.id}")

      click_link "Submit"

      within(".new_submission") do
        fill_in "Link", with: "http://www.umich.edu"
        click_button "Submit Assignment"
      end

      expect(page).to have_notification_message('notice', "#{assignment.name} was successfully submitted.")
    end

  end
  
end