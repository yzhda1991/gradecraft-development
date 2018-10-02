describe UsersController do
  include UniMock::StubRails

  let(:course) { create(:course) }
  let(:professor) { create(:user, courses: [course], role: :professor) }
  let(:student) { create(:user, courses: [course], role: :student) }
  let(:user) { create(:user, first_name: "Jimmy", courses: [course], role: :observer) }

  context "as a professor" do
    before(:each) { login_user(professor) }

    describe "GET index" do
      it "returns the users for the current course" do
        expect(get :index).to redirect_to(:root)
      end
    end

    describe "GET new" do
      it "assigns the name" do
        get :new
        expect(assigns(:user)).to be_a_new(User)
        expect(response).to render_template(:new)
      end
    end

    describe "GET edit" do
      it "renders the edit user form" do
        get :edit, params: { id: student.id }
        expect(assigns(:user)).to eq(student)
        expect(response).to render_template(:edit)
      end
    end

    describe "GET new_external" do
      it "redirects if the app instance is not beta" do
        stub_env "app"
        get :new_external
        expect(response).to redirect_to dashboard_path
      end
    end

    describe "POST create_external" do
      it "redirects if the app instance is not beta" do
        stub_env "app"
        post :create_external, params: { user: attributes_for(:user) }
        expect(response).to redirect_to dashboard_path
      end

      it "redirects if the user has not verified with the recaptcha" do
        stub_env "beta"
        allow(controller).to receive(:verify_recaptcha).and_return false
        post :create_external, params: { user: attributes_for(:user) }
        expect(response).to redirect_to new_external_users_path
      end
    end

    describe "PUT update" do
      it "updates an existing user" do
        user
        params = { first_name: "Jonathan" }
        put :update, params: { id: user.id, user: params }
        expect(user.reload.first_name).to eq "Jonathan"
      end

      it "activates the user if the user is not activated and the password changed" do
        allow(UserProctor).to receive(:new).and_return instance_double("UserProctor", can_update_password?: true)
        user = create :user, activated: false
        params = { password: "password", password_confirmation: "password" }
        put :update, params: { id: user.id, user: params }
        expect(user.reload.activated?).to be_truthy
      end

      it "does not allow the email to be updated" do
        user
        params = { email: "blah@blahblah.com" }
        put :update, params: { id: user.id, user: params }
        expect(user.reload.email).to_not eq "blah@blahblah.com"
      end
    end

    context "calling create" do
      it "creates a new staff member" do
        post :create, params: { user: { first_name: "Bob",
                  last_name: "Ross",
                  email: "bob.ross@mailinator.com",
                  course_memberships_attributes: { "0": {course_id: course.id,
                                                       role: "professor",
                                                       auditing: "0"}
                                                  }
                                        }
                                }
        expect(response).to redirect_to(staff_index_path)
      end

      it "creates a new observer" do
        post :create, params: { user: { first_name: "Bob",
                  last_name: "Ross",
                  email: "bob.ross@mailinator.com",
                  course_memberships_attributes: { "0": {course_id: course.id,
                                                       role: "observer",
                                                       auditing: "0"}
                                                  }
                                        }
                                }
        expect(response).to redirect_to(observers_path)
      end

      let(:user) { create(:user, first_name: "Bob", last_name: "Ross", email: "bob.ross@mailinator.com", courses: [course]) }

      it "returns an error for duplication if the user already exists" do
        post :create, params: { user: { first_name: "Bob",
                  last_name: "Ross",
                  email: "bob.ross@mailinator.com",
                  course_memberships_attributes: { "0": {course_id: course.id,
                                                       role: "student",
                                                       auditing: "0"}
                                                  }
                                        }
                                }
        post :create, params: { user: { first_name: "Bob",
                  last_name: "Ross",
                  email: "bob.ross@mailinator.com",
                  course_memberships_attributes: { "0": {course_id: course.id,
                                                       role: "student",
                                                       auditing: "0"}
                                                  }
                                        }
                                }
        expect(flash[:alert]).to include "already exists for"
      end

      it "deletes the password params if the user is not permitted to change it" do
        user_params = { password: "password", password_confirmation: "password" }
        allow(UserProctor).to receive(:new).with(user).and_return instance_double("UserProctor", can_update_password?: false)
        expect{ put :update, params: { id: user.id, user: user_params } }.to_not change { user.reload.crypted_password }
      end
    end

    # We used to allow instructors to delete users, but no longer (admins only)
    describe "GET destroy" do
      it "destroys the user" do
        student
        expect(get :destroy, params: { id: student }).to redirect_to(:root)
      end
    end

    describe "POST flag" do
      it "flags the student by the user if the student is not flagged" do
        post :flag, params: { id: student.id }, format: :js
        flagged_user = FlaggedUser.last
        expect(flagged_user.flagged_id).to eq student.id
        expect(flagged_user.flagger_id).to eq professor.id
        expect(flagged_user.course_id).to eq course.id
      end

      it "unflags the student if the student is already flagged" do
        FlaggedUser.flag! course, professor, student.id
        post :flag, params: { id: student.id }, format: :js
        expect(FlaggedUser.count).to be_zero
      end
    end

    describe "GET edit_profile" do
      it "renders the edit profile user form" do
        get :edit_profile
        expect(assigns(:user)).to eq(professor)
        expect(response).to render_template(:edit_profile)
      end
    end

    describe "POST update_profile" do
      it "successfully updates the users profile" do
        params = { time_zone: "Chihuahua" }
        post :update_profile, params: { id: professor.id, user: params }
        expect(response).to redirect_to(dashboard_path)
        expect(professor.reload.time_zone).to eq("Chihuahua")
      end
    end

    describe "GET import" do
      it "renders the import page if allowed" do
        stub_env "beta"
        get :import
        expect(response).to render_template(:import)
      end
    end

    describe "POST upload" do
      render_views

      let(:file) { fixture_file "users.csv", "text/csv" }
      before { create :team, course: course, name: "Zeppelin" }

      it "renders any errors that have occured" do
        file = fixture_file "users.xlsx"
        post :upload, params: { file: file }
        expect(flash[:notice]).to eq("We're sorry, the user import utility only supports .csv files. Please try again using a .csv file.")
        expect(response).to redirect_to(users_path)
      end

      it "renders the results from the import" do
        post :upload, params: { file: file }

        expect(response).to render_template :import_results
        expect(response.body).to include "3 Students Imported Successfully"
        expect(response.body).to include "csv_jimmy@example.com"
        expect(response.body).to include "csv_robert@example.com"
        expect(response.body).to include "whitespace@example.com"
      end

      it "renders any errors that have occured" do
        file = fixture_file "user_with_too_long_username.csv", "text/csv"
        post :upload, params: { file: file }
        expect(response.body).to include "1 Student Not Imported"
        expect(response.body).to include "csv_jimmy@example.com"
        expect(response.body).to include "Unable to create or update user"
      end

      it "renders any errors that occur with the team creation" do
        Team.unscoped.last.destroy
        allow_any_instance_of(Team).to receive(:valid?).and_return false
        allow_any_instance_of(Team).to receive(:errors).and_return double(full_messages: ["The team is not cool"])
        post :upload, params: { file: file }
        expect(response.body).to include "1 Student Not Imported"
        expect(response.body).to include "The team is not cool"
      end
    end

    describe "PUT manually_activate" do
      let(:unactivated_user) { create(:user)}
      it "activates the user" do
        put :manually_activate, params:{id:unactivated_user.id}
        expect(unactivated_user.activated?).to eq true
      end

      it "redirects to referer url if present" do
        request.env["HTTP_REFERER"] = "http://some-referer.com"
        put :manually_activate, params:{id:unactivated_user.id}
        expect(response).to redirect_to("http://some-referer.com")
      end

      it "redirects to dashboard if referer url is not present" do
        put :manually_activate, params:{id:unactivated_user.id}
        expect(response).to redirect_to(dashboard_path)
      end
    end

    describe "GET resend_activation_email" do
      let(:unactivated_user) { create(:user)}
      it "resend activation email to user" do
        expect {
            get :resend_activation_email, params:{ id: unactivated_user.id }
        }.to change  { ActionMailer::Base.deliveries.count }.by 1
      end

      it "redirects to referer url if present" do
        request.env["HTTP_REFERER"] = "http://some-referer.com"
        get :resend_activation_email, params:{ id:unactivated_user.id }
        expect(response).to redirect_to("http://some-referer.com")
      end

      it "redirects to dashboard if referer url is not present" do
        get :resend_activation_email, params:{ id: unactivated_user.id }
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  context "as a student" do
    before do
      login_user(student)
    end

    describe "GET activate" do
      before(:each) { student.update_attribute :activation_token, "blah" }

      it "exists" do
        get :activate, params: { id: student.activation_token }
        expect(response).to be_successful
      end

      it "redirects to the root url if the token is not correct" do
        get :activate, params: { id: "blech" }
        expect(response).to redirect_to root_path
      end
    end

    describe "POST activated" do
      before do
        student.update_attribute :activation_token, "blah"
        student.update_attribute :activation_state, "pending"
      end

      context "with matching passwords" do
        before do
          post :activated, params: { id: student.activation_token,
            token: student.activation_token,
            user: { password: "blah", password_confirmation: "blah" }}
        end

        it "activates the user" do
          expect(student.reload.activation_state).to eq "active"
        end

        it "updates the user's password" do
          expect(User.authenticate(student.email, "blah")).to eq student
        end

        it "logs the user in" do
          expect(response).to redirect_to dashboard_path
        end
      end

      context "with a tampered activation token" do
        before do
          post :activated, params: { id: student.activation_token,
            token: "tampered",
            user: { password: "blah", password_confirmation: "blah" }}
        end

        it "does not activate the user" do
          expect(student.reload.activation_state).to eq "pending"
        end

        it "does not update the user's password" do
          expect(User.authenticate(student.email, "blah")).to be_nil
        end

        it "redirects to the root url" do
          expect(response).to redirect_to root_path
        end
      end

      context "with a non-matching password" do
        before do
          post :activated, params: { id: student.activation_token,
            token: student.activation_token,
            user: { password: "blah", password_confirmation: "blech" }}
        end

        it "does not activate the user" do
          expect(student.reload.activation_state).to eq "pending"
        end

        it "renders the activate template" do
          expect(response).to render_template :activate
        end
      end

      context "with a blank password" do
        before do
          post :activated, params: { id: student.activation_token,
            token: student.activation_token,
            user: { password: "", password_confirmation: "" }}
        end

        it "does not activate the user" do
          expect(student.reload.activation_state).to eq "pending"
        end

        it "renders the activate template" do
          expect(response).to render_template :activate
        end
      end
    end

    describe "GET edit_profile" do
      it "renders the edit profile user form" do
        get :edit_profile
        expect(assigns(:user)).to eq(student)
        expect(response).to render_template(:edit_profile)
      end
    end

    describe "POST update_profile" do
      it "successfully updates the users profile" do
        params = { password: "", password_confirmation: "", time_zone: "Chihuahua" }
        post :update_profile, params: { id: student.id, user: params }
        expect(response).to redirect_to(dashboard_path)
        expect(student.reload.time_zone).to eq("Chihuahua")
      end

      it "successfully updates the user's password" do
        params = { password: "test", password_confirmation: "test" }
        post :update_profile, params: { id: student.id, user: params }
        expect(response).to redirect_to(dashboard_path)
        expect(User.authenticate(student.email, "test")).to eq student
      end
    end

    describe "protected routes" do
      [
        :index,
        :new,
        :create,
        :import,
        :upload
      ].each do |route|
          it "#{route} redirects to root" do
            expect(get route).to redirect_to(:root)
          end
        end
    end

    describe "protected routes requiring id in params" do
      [
        :edit,
        :update,
        :destroy,
        :manually_activate
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, params: { id: "1" }).to redirect_to(:root)
        end
      end
    end
  end
end
