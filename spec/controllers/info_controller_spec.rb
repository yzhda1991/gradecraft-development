require 'rails_spec_helper'

describe InfoController do
  before(:all) { @course = create(:course) }
  before(:each) do
    session[:course_id] = @course.id
    allow(Resque).to receive(:enqueue).and_return(true)
  end

  context "as a professor" do
    before(:all) do
      @professor = create(:user)
      CourseMembership.create user: @professor, course: @course, role: "professor"
    end
    before { login_user(@professor) }

    describe "GET dashboard" do
      it "retrieves the dashboard" do
        skip "implement"
        get :dashboard
        expect(response).to render_template(:dashboard)
      end
    end

    describe "GET timeline_events" do
      it "retrieves the timeline events" do
        get :timeline_events
        expect(response).to render_template("info/_timeline")
      end
    end

    describe "GET awarded_badges" do
      it "retrieves the awarded badges page" do
        get :awarded_badges
        expect(response).to render_template(:awarded_badges)
      end
    end

    describe "GET grading_status" do
      it "retrieves the grading_status page" do
        get :grading_status
        expect(response).to render_template(:grading_status)
      end
    end

    describe "GET resubmissions" do
      it "retrieves the resubmissions page" do
        get :resubmissions
        expect(response).to render_template(:resubmissions)
      end
    end

    describe "GET ungraded_submissions" do
      it "retrieves the ungraded submissions page" do
        get :ungraded_submissions
        expect(response).to render_template(:ungraded_submissions)
      end
    end

    describe "GET gradebook" do
      it "retrieves the gradebook" do
        expect(GradebookExporterJob).to \
          receive(:new).with(user_id: @professor.id, course_id: @course.id)
            .and_call_original
        expect_any_instance_of(GradebookExporterJob).to receive(:enqueue)
        get :gradebook
      end

      it "redirects to the root path if there is no referer" do
        get :gradebook
        expect(response).to redirect_to root_path
      end

      it "redirects to the referer if there is one" do
        request.env["HTTP_REFERER"] = dashboard_path
        get :gradebook
        expect(response).to redirect_to dashboard_path
      end
    end

    describe "GET multipled_gradebook" do
      it "retrieves the multiplied gradebook" do
        expect(MultipliedGradebookExporterJob).to \
          receive(:new).with(user_id: @professor.id, course_id: @course.id)
            .and_call_original
        expect_any_instance_of(MultipliedGradebookExporterJob).to receive(:enqueue)
        get :multiplied_gradebook
      end

      it "redirects to the root path if there is no referer" do
        get :multiplied_gradebook
        expect(response).to redirect_to root_path
      end

      it "redirects to the referer if there is one" do
        request.env["HTTP_REFERER"] = dashboard_path
        get :multiplied_gradebook
        expect(response).to redirect_to dashboard_path
      end
    end

    describe "GET final_grades" do
      it "retrieves the final_grades download" do
        skip "implement"
        get :final_grades
        expect(response).to render_template(:final_grades)
      end
    end

    describe "GET research_gradebook" do
      it "retrieves the research_gradebook" do
        skip "implement"
        get :research_gradebook
        expect(response).to render_template(:research_gradebook)
      end
    end

    describe "GET choices" do
      it "retrieves the choices" do
        get :choices
        expect(assigns(:title)).to eq("Multiplier Choices")
        expect(response).to render_template(:choices)
      end
    end

    describe "GET all_grades" do
      it "retrieves the all grades" do
        skip "implement"
        get :all_grades
        expect(response).to render_template(:all_grades)
      end
    end
  end

  context "as a student" do
    before(:all) do
      @student = create(:user)
      @student.courses << @course
    end
    before(:each) { login_user(@student) }

    describe "GET dashboard" do
      it "retrieves the dashboard" do
        skip "implement"
        get :dashboard
        expect(response).to render_template(:dashboard)
      end
    end

    describe "GET timeline_events" do
      it "retrieves the timeline events" do
        get :timeline_events
        expect(response).to render_template('info/_timeline')
      end
    end

    describe "protected routes" do
      [
        :awarded_badges,
        :grading_status,
        :resubmissions,
        :ungraded_submissions,
        :gradebook,
        :multiplied_gradebook,
        :final_grades,
        :research_gradebook,
        :choices,
        :all_grades
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route).to redirect_to(:root)
        end
      end
    end
  end
end
