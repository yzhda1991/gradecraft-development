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
      let(:user) { build(:user, email: "#{Faker::Internet.user_name}@umich.edu") }

      scenario "successfully" do
        within(".pageContent") do
          NewUserPage.new(user)
            .submit(internal: true, courses: [course_membership.course])

          expect(current_path).to eq students_path
          expect(page).to have_notification_message "notice", "#{course_membership.course.user_term} #{user.name} was successfully created!"

          result = User.unscoped.last
          expect(result.first_name).to eq user.first_name
          expect(result.last_name).to eq user.last_name
          expect(result.email).to eq user.email
          expect(result.username).to eq user.username
          expect(result.crypted_password).to be_nil
        end
      end
    end
  end
end
