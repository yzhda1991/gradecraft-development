require "rails_spec_helper"

describe API::StudentsController do
  let(:course) { create(:course)}
  let!(:student)  { create(:course_membership, :student, course: course).user }
  let(:professor) { create(:course_membership, :professor, course: course).user }

  context "as a professor" do
    before do
      login_user(professor)
      allow(controller).to receive(:current_course).and_return(course)
    end

    describe "GET index" do
      it "returns students and ids" do
        get :index, format: :json
        expect(JSON.parse(response.body)).to eq([{"name"=>"#{student.name}", "id"=>student.id}])
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
