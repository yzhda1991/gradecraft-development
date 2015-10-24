require "spec_helper"

feature "submitting an assignment", focus: true do
  let(:password) { "p@ssword" }

  context "as a student" do
    let!(:course_membership) { create :student_course_membership, user: user }
    let(:user) { create :user, password: password }
    let(:assignment) {create :individual_assignment_with_submissions}

    before { visit root_path }

    before(:each) do
      LoginPage.new(user).submit({ password: password })
    end

    scenario "successfully" do

      visit syllabus_path

      click_link "#{assignment.name}"

      expect(page).to have_content assignment.name
    end

  end
  
end