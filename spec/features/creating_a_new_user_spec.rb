require "rails_spec_helper"

feature "creating a new user" do
  context "as an administrator" do
    let!(:course_membership) { create :admin_course_membership, user: admin }
    let(:admin) { create :user }

    before(:each) do
      login_as admin
      visit new_user_path
    end

    context "for a UM student" do
      scenario "successfully" do
        within(".pageContent") do
          new_user = build(:user)
          NewUserPage.new(new_user)
            .submit(internal: true, courses: [course_membership.course])

          expect(current_path).to eq students_path
          expect(page).to have_notification_message("notice", "#{course_membership.course.user_term} #{new_user.name} was successfully created!")

          user = User.unscoped.last
          expect(user.first_name).to eq new_user.first_name
          expect(user.last_name).to eq new_user.last_name
          expect(user.email).to eq new_user.email
          expect(user.username).to eq new_user.username
          expect(user.crypted_password).to be_nil
        end
      end
    end
  end
end
