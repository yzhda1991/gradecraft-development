feature "editing a user", focus: true do
  context "as an administrator" do
    let(:course) { build :course }
    let(:admin) { build :user, role: :admin, courses: [course] }
    let(:student) { build :user, first_name: "Hermione", last_name: "Granger", courses: [course], role: :student }

    before(:each) do
      login_as admin
      visit edit_user_path(student)
    end

    context "for an existing GradeCraft student" do
      scenario "successfully" do
        # fill_in 'Password', with: "crookshanks"
        # fill_in "Password Confirmation", with: "crookshanks"
        fill_in "First Name", with: "H2"

        click_button "Update User"

        expect(current_path).to eq students_path
        expect(page).to have_notification_message "notice", "#{course_membership.course.student_term} #{user.name} was successfully updated!"
      end
    end
  end
end
