require "rails_spec_helper"

feature "switch course" do

  context "as a student" do
    let(:course_1) { create :course }
    let!(:course_membership) { create :student_course_membership, user: student, course: course_1 }
    let(:course_2) { create :course }
    let!(:second_course_membership) { create :student_course_membership, user: student, course: course_2 }
    let(:student) { create :user }

    before(:each) do
      login_as student
      visit syllabus_path
    end

    scenario "successfully" do

      within("#course-list") do
        click_link "#{course_2.formatted_short_name}"
      end

      expect(page).to have_content course_2.name
    end

  end
  
end
