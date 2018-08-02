describe API::CoursesController do
  let!(:course) { create :course }
  let(:student)  { create(:course_membership, :student, course: course).user }
  let(:professor) { create(:course_membership, :professor, course: course).user }

  context "as an admin" do
    let(:admin) { create :user, courses: [course], role: :admin }

    before(:each) { login_user admin }

    describe "GET search" do
      it "returns a hash of search attributes for the user's courses" do
        get :search, format: :json
        body = JSON.parse(response.body)
        expect(body).to include "id" => course.id,
          "formatted_name" => course.formatted_long_name,
          "search_string" => course.searchable_name
      end
    end

    describe "GET index" do
      let!(:another_course) { create :course }

      context "when only course ids are requested" do
        it "returns ids for all courses that currently exist" do
          get :index, params: { fetch_ids: 1 }, format: :json
          body = JSON.parse(response.body)
          expect(body).to include "course_ids"
          expect(body["course_ids"]).to match_array Course.pluck(:id)
        end
      end

      context "when not requesting course ids" do
        it "assigns all existing courses if no subset is provided" do
          get :index, format: :json
          expect(assigns(:courses)).to match_array Course.all
        end

        it "assigns only the requested courses if provided" do
          get :index, params: { course_ids: [another_course.id]}, format: :json
          expect(assigns(:courses)).to eq [another_course]
        end
      end
    end
  end

  context "as a professor" do
    before do
      login_user professor
      allow(controller).to receive(:current_course).and_return course
    end

    describe "GET index" do
      it "returns course info for only the professor's courses" do
        outside_course = create :course #shouldn't appear in index
        get :index, format: :json
        expect(assigns(:courses).length).to eq 1
      end
    end

    describe "GET analytics" do
      it "returns analytics data for the course" do
        get :analytics, format: :json
        expect(assigns(:course)).to eq course
        expect(assigns(:student)).to be_nil
        expect(assigns(:user_score)).to be_nil
      end
    end

    describe "GET timeline_events" do
      it "returns a list of events for the dashboard" do
        create :event, course: course, name: "Course-Event", due_at: Date.today
        get :timeline_events, format: :json
        expect(assigns(:events)).to eq Timeline.new(course).events_by_due_date
      end
    end
  end

  context "as a student" do
    before do
      login_user student
    end

    describe "GET index" do
      it "redirects" do
        outside_course = create :course #shouldn't appear in index
        get :index, format: :json
        expect(assigns(:courses).length).to eq(1)
      end
    end

    describe "GET analytics" do
      it "returns analytics data for the course" do
        get :analytics, format: :json
        expect(assigns(:course)).to eq course
        expect(assigns(:student)).to eq student
        expect(assigns(:user_score)).to eq student.score_for_course(course)
      end
    end

    describe "GET timeline_events" do
      it "returns a list of events for the dashboard" do
        create :event, course: course, name: "Course-Event", due_at: Date.today
        get :timeline_events, format: :json
        expect(assigns(:events)).to eq Timeline.new(course).events_by_due_date
      end
    end
  end
end
