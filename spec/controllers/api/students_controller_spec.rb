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

    describe "GET analytics" do


      describe "#total_scores_for_chart" do
        it "handles the summing of earned badges, including old badges cached with nil points" do
          course = double(:course, assignment_types: [], badge_term: "Badgeinskies", total_points: 0)

          earned_badges = double(:earned_badges, sum: 1000)
          user = double(:user, earned_badges: earned_badges)
          expect(helper.total_scores_for_chart(user,course)).to eq({scores_by_assignment_type: [{ data: 1000, name: "Badgeinskies" }], course_total: 1000 })
        end
      end


    end
  end
end
