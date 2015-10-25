require "spec_helper"

feature "creating a new course" do
  let(:password) { "p@ssword" }

  context "as an admin", focus: true do
    let!(:course_membership) { create :admin_course_membership, user: user }
    let(:user) { create :user, password: password }

    before { visit root_path }

    before(:each) do
      LoginPage.new(user).submit({ password: password })
    end

    scenario "successfully" do
      within("#mycourses") do
        click_link "Create a New Course"
      end

      within(".pageContent") do
        fill_in "Course Title", with: "Course Name"
        fill_in "Course Number", with: "101"
        click_button "Create Course"
      end

      expect(current_path).to eq course_path(Course.last)
      within("header") do
        expect(page).to have_content user.display_name
      end

    end
  end

  context "as a professor" do
    let!(:course_membership) { create :professor_course_membership, user: user }
    let(:user) { create :user, password: password }

    before { visit root_path }

    before(:each) do
      LoginPage.new(user).submit({ password: password })
    end

    scenario "successfully" do
      within("#mycourses") do
        click_link "Create a New Course"
      end

      within(".pageContent") do
        fill_in "Course Title", with: "Course Name"
        fill_in "Course Number", with: "102"
        click_button "Create Course"
      end

    end
  end
  
end
