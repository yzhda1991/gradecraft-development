describe InfoController do
  let(:course) { create(:course) }
  let(:course_2) { create(:course) }
  let(:professor) { create(:user, courses: [course], role: :professor) }
  let(:assignment) { create(:assignment_with_due_at, course: course) }
  let(:student) { create(:user, courses: [course, course_2], role: :student) }
  let(:observer) { create(:user, courses: [course], role: :observer) }

  context "as a professor" do
    before { login_user(professor) }

    describe "GET dashboard" do
      context "when a role is present in the current course" do
        it "retrieves the dashboard" do
          get :dashboard
          expect(response).to render_template :dashboard
        end
      end

      context "when no role is present for the current course" do
        let(:professor) { create :user }
        before(:each) { allow(controller).to receive(:current_course).and_return course }

        it "changes to the first available course if it exists" do
          create :course_membership, :professor, course: course_2, user: professor
          get :dashboard
          expect(response).to redirect_to change_course_path(course_2)
        end

        it "redirects to an error page if they don't belong to any other courses" do
          get :dashboard
          expect(response).to redirect_to errors_path(status_code: 401, error_type: "without_course_membership")
        end
      end
    end

    describe "GET predictor" do
      it "shows the grade predictor page" do
        get :predictor, params: { id: 10 }
        expect(response).to render_template(:predictor)
      end
    end

    describe "GET earned_badges" do
      it "retrieves the awarded badges page" do
        get :earned_badges
        expect(response).to render_template(:earned_badges)
      end
    end

    describe "GET grading_status" do
      it "retrieves the grading_status page" do
        get :grading_status
        expect(response).to render_template(:grading_status)
      end
    end

    describe "GET per_assign" do
      it "returns the Assignment Analytics page for the current course" do
        get :per_assign
        expect(response).to render_template(:per_assign)
      end
    end

    describe "GET gradebook_file" do
      it "retrieves the gradebook" do
        expect(GradebookExporterJob).to \
          receive(:new).with(user_id: professor.id, course_id: course.id, filename: "#{ course.name } Gradebook - #{ Date.today }.csv")
            .and_call_original
        expect_any_instance_of(GradebookExporterJob).to receive(:enqueue)
        get :gradebook_file, params: { id: course.id }
      end

      it "redirects to the root path if there is no referer" do
        get :gradebook_file, params: { id: course.id }
        expect(response).to redirect_to root_path
      end

      it "redirects to the referer if there is one" do
        request.env["HTTP_REFERER"] = dashboard_path
        get :gradebook_file, params: { id: course.id }
        expect(response).to redirect_to dashboard_path
      end
    end

    describe "GET multipled_gradebook" do
      it "retrieves the multiplied gradebook" do
        expect(MultipliedGradebookExporterJob).to \
          receive(:new).with(user_id: professor.id, course_id: course.id, filename: "#{ course.name } Multiplied Gradebook - #{ Date.today }.csv")
            .and_call_original
        expect_any_instance_of(MultipliedGradebookExporterJob).to receive(:enqueue)
        get :multiplied_gradebook, params: { id: course.id }
      end

      it "redirects to the root path if there is no referer" do
        get :multiplied_gradebook, params: { id: course.id }
        expect(response).to redirect_to root_path
      end

      it "redirects to the referer if there is one" do
        request.env["HTTP_REFERER"] = dashboard_path
        get :multiplied_gradebook, params: { id: course.id }
        expect(response).to redirect_to dashboard_path
      end
    end

    describe "GET export_earned_badges" do
      it "retrieves the export_earned_badges download" do
        get :export_earned_badges, params: { id: course.id }, format: :csv
        expect(response.body).to include("First Name,Last Name,Uniqname,Email,Badge ID,Badge Name,Feedback,Awarded Date")
      end
    end

    describe "GET final_grades" do
      it "retrieves the final_grades download" do
        get :final_grades, params: { id: course.id }, format: :csv
        expect(response.body).to include("First Name,Last Name,Email,Username,Score,Grade")
      end
    end

    describe "GET research_gradebook" do
      it "retrieves the research gradebook" do
        expect(GradeExportJob).to \
          receive(:new).with(user_id: professor.id, course_id: course.id, filename: "#{ course.name } Research Gradebook - #{ Date.today }.csv")
            .and_call_original
        expect_any_instance_of(GradeExportJob).to receive(:enqueue)
        get :research_gradebook, params: { id: course.id }
      end

      it "redirects to the root path if there is no referer" do
        get :research_gradebook, params: { id: course.id }
        expect(response).to redirect_to root_path
      end

      it "redirects to the referer if there is one" do
        request.env["HTTP_REFERER"] = dashboard_path
        get :research_gradebook, params: { id: course.id }
        expect(response).to redirect_to dashboard_path
      end
    end

    describe "GET multiplier_choices" do
      it "retrieves the choices" do
        get :multiplier_choices
        expect(response).to render_template(:multiplier_choices)
      end

      it "only shows the students for the team" do
        @team = create(:team, course: course)
        student = create(:user, courses: [course], role: :student)
        student.teams << @team
        student_2 = create(:user, courses: [course], role: :student)
        get :multiplier_choices, params: { team_id: @team.id }
        expect(response).to render_template(:multiplier_choices)
        expect(assigns(:students)).to eq([student])
      end
    end

    describe "GET submission export" do
      it "retrieves the submission export" do
        expect(SubmissionExportJob).to \
          receive(:new).with(user_id: professor.id, course_id: course.id, filename: "#{ course.name } Submissions Export - #{ Date.today }.csv")
            .and_call_original
        expect_any_instance_of(SubmissionExportJob).to receive(:enqueue)
        get :submissions, params: { id: course.id }
      end

      it "redirects to the root path if there is no referer" do
        get :submissions, params: { id: course.id }
        expect(response).to redirect_to root_path
      end

      it "redirects to the referer if there is one" do
        request.env["HTTP_REFERER"] = dashboard_path
        get :submissions, params: { id: course.id }
        expect(response).to redirect_to dashboard_path
      end
    end
  end

  context "as a student" do
    before(:each) { login_user(student) }

    describe "GET dashboard" do
      it "retrieves the dashboard if turned on" do
        get :dashboard
        expect(response).to render_template(:dashboard)
      end

      it "ensures access to the current course" do
        expect(controller).to receive(:ensure_current_course_role?)
        get :dashboard
      end
    end

    describe "GET predictor" do
      it "shows the grade predictor page" do
        get :predictor
        expect(response).to render_template(:predictor)
      end
    end

    describe "protected routes" do
      [
        :earned_badges,
        :grading_status,
        :per_assign,
        :gradebook_file,
        :gradebook,
        :multiplied_gradebook,
        :final_grades,
        :research_gradebook,
        :multiplier_choices
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route).to redirect_to(:root)
        end
      end
    end
  end

  context "as an observer" do
    before(:each) { login_user(observer) }

    describe "GET predictor" do
      it "shows the grade predictor page" do
        expect(get :predictor).to render_template(:predictor)
      end
    end

    describe "protected routes" do
      [
        :dashboard,
        :earned_badges,
        :grading_status,
        :per_assign,
        :gradebook,
        :multiplied_gradebook,
        :final_grades,
        :research_gradebook,
        :multiplier_choices
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route).to redirect_to(assignments_path)
        end
      end
    end
  end
end
