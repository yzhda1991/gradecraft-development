require "rails_spec_helper"

describe API::CoursesController do
  let!(:course) { create(:course)}
  let!(:other_course) { create(:course)}
  let(:student)  { create(:course_membership, :student, course: course).user }
  let(:professor) { create(:course_membership, :professor, course: course).user }

  context "as a professor" do
    before do
      login_user(professor)
      allow(controller).to receive(:current_course).and_return(course)
    end

    describe "GET index" do
      it "returns course info for only the professor's courses" do
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



