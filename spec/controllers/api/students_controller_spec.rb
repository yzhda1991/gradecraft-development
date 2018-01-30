describe API::StudentsController do
  let(:course) { build(:course)}
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
        expect(JSON.parse(response.body)).to eq([{
          "name"=>"#{student.name}",
          "id"=>student.id,
          "search_string"=>"#{student.name } #{student.email}"
          }])
        expect(response.status).to eq(200)
      end
    end

    describe "GET student analytics" do

      it "assigns information for charting course progress" do
        assignment_type = create(:assignment_type, course: course)
        allow(course).to receive(:total_points).and_return 1000
        get :student_analytics, params: {id: student.id}, format: :json

        expect(assigns(:student)).to eq(student)
        expect(assigns(:assignment_types)).to eq([assignment_type])
        expect(assigns(:course_potential_points_for_student)).to eq(1000)
      end
    end
  end

  context "as a student" do
    before do
      login_user(student)
      allow(controller).to receive(:current_course).and_return(course)
    end

    describe "GET index" do
      it "redirects" do
        get :index, format: :json
        expect(response).to have_http_status :ok
      end
    end

    describe "GET student analytics" do
      it "redirects" do
        get :student_analytics, params: {id: student.id}, format: :json
        expect(response.status).to eq(302)
      end
    end

    describe "GET analytics" do

      it "assigns information for charting course progress" do
        assignment_type = create(:assignment_type, course: course)
        badge = create(:badge, full_points: 600)
        create :earned_badge, badge: badge, course: course, student: student
        allow(course).to receive(:total_points).and_return 1000
        get :analytics, format: :json

        expect(assigns(:student)).to eq(student)
        expect(assigns(:assignment_types)).to eq([assignment_type])
        expect(assigns(:earned_badge_points)).to eq(600)
        expect(assigns(:course_potential_points_for_student)).to eq(1600)
      end
    end
  end
end
