require "rails_spec_helper"

describe API::Grades::GradeFilesController do
  let(:world) { World.create.with(:course, :student, :assignment, :grade) }
  let(:professor) { create(:professor_course_membership, course: world.course).user }

  context "as professor" do
    before(:each) { login_user(professor) }

    describe "POST create" do
      it "adds upload file to grade" do
        grade_file = fixture_file("Too long, strange characters, and Spaces (In) Name.jpg", "img/jpg")
        post :create, params: { grade_id: world.grade.id, grade_files: [grade_file] },
          format: :json
        expect(world.grade.grade_files.count).to eq(1)
      end
    end

    describe "DELETE destroy" do
      let!(:grade_file) { create :grade_file, grade: world.grade }
      let(:stub_grade_file) { allow(GradeFile).to receive(:where) { [grade_file] }}

      it "destroys the grade file" do
        delete :destroy, grade_id: world.grade.id, id: grade_file.id, format: :json
        world.grade.reload
        expect(world.grade.grade_files.count).to eq(0)
      end

      it "removes the corresponding file on s3" do
        stub_grade_file
        expect(grade_file).to receive(:delete_from_s3)
        delete :destroy, grade_id: world.grade.id, id: grade_file.id, format: :json
      end
    end
  end

  context "as student" do
    before(:each) { login_user(world.student) }

    describe "POST create" do
      it "is a protected route" do
        expect(post :create, params: { grade_id: world.grade.id }, format: :json).to \
          redirect_to(:root)
      end
    end

    describe "DELETE destroy" do
      it "is a protected route" do
        grade_file = create(:grade_file, grade: world.grade)
        expect(delete :destroy, grade_id: world.grade.id, id: grade_file.id, format: :json).to redirect_to(:root)
      end
    end
  end
end
