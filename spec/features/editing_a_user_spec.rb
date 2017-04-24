feature "editing a user" do
  context "as an administrator" do
    let(:course) { build :course }
    let(:admin) { create :user, role: :admin, courses: [course] }
    let(:student) { create :user, first_name: "Hermione", last_name: "Granger", courses: [course], kerberos_uid: nil, role: :student }

    before(:each) do
      login_as admin
      visit edit_user_path(student.id)
    end

    context "updating a GradeCraft student" do
      scenario "setting a new password successfully" do
        fill_in "Password", with: "crookshanks"
        fill_in "Password confirmation", with: "crookshanks"

        find('input[name="commit"]').click

        expect(current_path).to eq students_path
        expect(page).to have_notification_message "notice", "#{course.student_term} #{student.name} was successfully updated!"
      end

      scenario "updating a name but not a password" do
        visit edit_user_path(student.id)
        fill_in "First name", with: "The Amazing Hermione"

        find('input[name="commit"]').click

        expect(current_path).to eq students_path
        expect(page).to have_notification_message "notice", "#{course.student_term} The Amazing Hermione Granger was successfully updated!"
      end
    end
  end
end
