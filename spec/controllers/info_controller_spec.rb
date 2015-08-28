#spec/controllers/info_controller_spec.rb
require 'spec_helper'

describe InfoController do

  before do
    allow(Resque).to receive(:enqueue).and_return(true)
  end

  context "as a professor" do

    before do
      @course = create(:course)
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
      @assignment_1 = create(:assignment, course: @course)
      @assignment_2 = create(:assignment, course: @course)
      login_user(@professor)
      session[:course_id] = @course.id
    end

    describe "GET dashboard" do
      it "retrieves the dashboard" do
        skip "implement"
        get :dashboard
        expect(response).to render_template(:dashboard)
      end
    end

    describe "GET timeline_events" do
      it "retrieves the timeline events" do
        @events = []
        @events << [@assignment_1, @assignment_2]
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
        skip "implement"
        get :gradebook
        expect(response).to render_template(:gradebook)
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

    before do
      @course = create(:course)
      @student = create(:user)
      @student.courses << @course

      login_user(@student)
      session[:course_id] = @course.id
    end

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
