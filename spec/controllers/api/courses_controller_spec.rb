describe API::CoursesController do
  let!(:course) { build(:course)}
  let(:student)  { create(:course_membership, :student, course: course).user }
  let(:professor) { create(:course_membership, :professor, course: course).user }

  context "as a professor" do
    before do
      login_user(professor)
      allow(controller).to receive(:current_course).and_return(course)
    end

    describe "GET index" do
      it "returns course info for only the professor's courses" do
        outside_course = create(:course) #shouldn't appear in index
        get :index, format: :json
        expect(assigns(:courses).length).to eq(1)
      end
    end

    describe "GET analytics" do
      it "returns analytics data for the course" do
        get :analytics, format: :json
        expect(assigns(:course)).to eq(course)
        expect(assigns(:student)).to be_nil
        expect(assigns(:user_score)).to be_nil
      end
    end

    describe "GET timeline_events" do
      it "returns a list of events for the dashboard" do
        create :event, course: course, name: "Course-Event", due_at: Date.today
        get :timeline_events, format: :json
        expect(assigns(:events)).to eq(Timeline.new(course).events_by_due_date)
      end
    end
  end

  context "as a student" do
    before do
      login_user(student)
    end

    describe "GET index" do
      it "redirects" do
        outside_course = create(:course) #shouldn't appear in index
        get :index, format: :json
        expect(assigns(:courses).length).to eq(1)
      end
    end

    describe "GET analytics" do
      it "returns analytics data for the course" do
        get :analytics, format: :json
        expect(assigns(:course)).to eq(course)
        expect(assigns(:student)).to eq(student)
        expect(assigns(:user_score)).to eq(student.score_for_course(course))
      end
    end

    describe "GET timeline_events" do
      it "returns a list of events for the dashboard" do
        create :event, course: course, name: "Course-Event", due_at: Date.today
        get :timeline_events, format: :json
        expect(assigns(:events)).to eq(Timeline.new(course).events_by_due_date)
      end
    end
  end
end
