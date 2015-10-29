require "spec_helper"

feature "switch course", focus: true do

  context "as a student" do
    let(:course_1) { create :course }
    let!(:course_membership) { create :student_course_membership, user: user, course: course_1 }
    let(:course_2) { create :course }
    let!(:second_course_membership) { create :student_course_membership, user: user, course: course_2 }
    let(:user) { create :user, password: 'p@ssword' }

    before(:each) do
      login_user(user, 'p@ssword')
    end

    scenario "successfully" do

      within("#course-list") do
        click_link "#{course_2.formatted_short_name}"
      end

      expect(page).to have_content course_2.name
    end

  end
  
end
