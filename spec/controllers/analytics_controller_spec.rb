require "spec_helper"

describe AnalyticsController do
  before { allow(Resque).to receive(:enqueue).and_return(true) }

  context "as a professor" do
    before(:all) do
      @course = create(:course)
      @professor = create(:user, courses: [@course], role: :professor)
    end

    before(:each) do
      session[:course_id] = @course.id
      login_user(@professor)
    end

    describe "GET students" do
      it "returns the student analytics page for the current course" do
        get :students
        expect(response).to render_template(:students)
      end
    end

    describe "GET staff" do
      it "returns the staff analytics page for the current course" do
        get :staff
        expect(response).to render_template(:staff)
      end
    end
  end

  context "as a student" do
    before(:all) do
      @course = create(:course)
      @student = create(:user, courses: [@course], role: :student)
    end

    before(:each) do
      session[:course_id] = @course.id
      login_user(@student)
    end

    describe "protected routes" do
      [
        :students,
        :staff,
        :all_events,
        :role_events,
        :login_events,
        :login_role_events,
        :all_pageview_events,
        :all_role_pageview_events,
        :all_user_pageview_events,
        :pageview_events,
        :role_pageview_events,
        :user_pageview_events
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route).to redirect_to(:root)
        end
      end
    end
  end
end
