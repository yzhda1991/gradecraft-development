require 'rails_spec_helper'

describe InfoController do
  before(:all) { @course = create(:course) }
  before(:all) { @course_2 = create(:course_without_timeline) }
  before(:each) do
    session[:course_id] = @course.id
    allow(Resque).to receive(:enqueue).and_return(true)
  end

  context "as a professor" do
    before(:all) do
      @professor = create(:user)
      CourseMembership.create user: @professor, course: @course, role: "professor"
      CourseMembership.create user: @professor, course: @course_2, role: "professor"
    end
    before { login_user(@professor) }

    describe "GET dashboard" do
      it "retrieves the timeline if turned on" do
        @assignment = create(:assignment, course: @course)
        get :dashboard
        expect(response).to render_template(:dashboard)
      end

      it "retrieves the Top 10 if timeline is turned off" do
        session[:course_id] = @course_2.id
        get :dashboard
        expect(response).to redirect_to top_10_path
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

    describe "GET top_10" do
      it "returns the Top 10/Bottom 10 page for the current course" do
        get :top_10
        expect(assigns(:title)).to eq("Top 10/Bottom 10")
        expect(response).to render_template(:top_10)
      end
    end

    describe "GET per_assign" do
      it "returns the Assignment Analytics page for the current course" do
        get :per_assign
        expect(assigns(:title)).to eq("assignment Analytics")
        expect(response).to render_template(:per_assign)
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
        get :final_grades, :format => :csv
        expect(response.body).to include("First Name,Last Name,Email,Username,Score,Grade")
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
  end

  context "as a student" do
    before(:all) do
      @student = create(:user)
      @student.courses << @course
      @student.courses << @course_2
    end
    before(:each) { login_user(@student) }

    describe "GET dashboard" do
      it "retrieves the timeline if turned on" do
        get :dashboard
        expect(response).to render_template(:dashboard)
      end

      it "retrieves the Syllabus if timeline is turned off" do
        session[:course_id] = @course_2.id

        get :dashboard
        expect(response).to redirect_to syllabus_path
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
        :top_10, 
        :per_assign,
        :gradebook,
        :multiplied_gradebook,
        :final_grades,
        :research_gradebook,
        :choices
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route).to redirect_to(:root)
        end
      end
    end
  end
end
