require "rails_spec_helper"

describe API::CoursesController do
  let!(:course) { create(:course)}
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
        json = JSON.parse(response.body)
        expect(json.length).to eq(1)
        expect(json).to eq(
          [{"id"=>course.id,
            "name"=>course.name,
            "course_number"=>course.course_number,
            "year"=>course.year,
            "semester"=>course.semester}
          ])
        expect(response.status).to eq(200)
      end
    end

    describe "GET timeline_events" do
      it "returns a list of events for the dashboard" do
        create :event, course: course, name: "Course-Event", due_at: Date.today
        get :timeline_events, format: :json
        expect(assigns(:events)).to eq(Timeline.new(course).events_by_due_date)
        expect(response).to render_template("api/courses/timeline_events")
      end
    end
  end

  context "as a student" do
    before do
      login_user(student)
    end

    describe "GET index" do
      it "redirects" do
        get :index, format: :json
        expect(response.status).to eq(302)
      end
    end
  end
end



