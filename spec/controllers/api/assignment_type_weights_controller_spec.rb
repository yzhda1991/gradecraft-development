describe API::AssignmentTypeWeightsController do
  let(:course) { build :course }
  let(:student)  { create(:course_membership, :student, course: course).user }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:assignment_type) { create(:assignment_type, course: course) }

  context "as professor" do
    before(:each) { login_user(professor) }

    describe "POST create" do
      it "is a protected route" do
        expect(post :create,
               params: { assignment_type_id: assignment_type.id, weight: 4 },
               format: :json).to redirect_to(:root)
      end
    end
  end

  context "as student" do
    before(:each) { login_user(student) }

    describe "create" do
      it "returns 400 if the assignment type is not weightable" do
        post :create, params: { assignment_type_id: assignment_type.id, weight: 4 },
          format: :json
        expect(response.status).to eq(404)
      end

      it "updates the student's weight" do
        assignment_type.update(student_weightable: true)
        post :create, params: { assignment_type_id: assignment_type.id, weight: 4 },
          format: :json
        expect(assignment_type.weight_for_student(student)).to eq(4)
      end
    end
  end
end
