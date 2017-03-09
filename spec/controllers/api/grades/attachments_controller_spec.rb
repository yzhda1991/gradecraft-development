require "rails_spec_helper"

describe API::Grades::AttachmentsController, focus: true do
  let(:course) { create :course }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:student) { create(:course_membership, :student, course: course).user }
  let(:team) { create(:team, course: course) }
  let(:challenge) { create(:challenge, course: course) }
  let(:grade) { create(:grade, student: student) }

  context "as professor" do
    before(:each) { login_user(professor) }

    describe "POST create" do
      it "adds upload file to grade" do
        file_upload = fixture_file("Too long, strange characters, and Spaces (In) Name.jpg", "img/jpg")
        post :create, params: { grade_id: grade.id, file_uploads: [file_upload] },
          format: :json
        expect(grade.file_uploads.count).to eq(1)
      end
    end

    describe "DELETE destroy" do
      let!(:file_upload) { create :file_upload, grade: grade }
      let(:stub_file_upload) { allow(FileUpload).to receive(:where) { [file_upload] }}

      it "destroys the grade file" do
        delete :destroy, params: { grade_id: grade.id, id: file_upload.id }, format: :json
        grade.reload
        expect(grade.file_uploads.count).to eq(0)
      end

      it "removes the corresponding file on s3" do
        stub_file_upload
        expect(file_upload).to receive(:delete_from_s3)
        delete :destroy, params: { grade_id: grade.id, id: file_upload.id }, format: :json
      end
    end
  end

  context "as student" do
    before(:each) { login_user(student) }

    describe "POST create" do
      it "is a protected route" do
        expect(post :create, params: { grade_id: grade.id }, format: :json).to \
          redirect_to(:root)
      end
    end

    describe "DELETE destroy" do
      it "is a protected route" do
        file_upload = create(:file_upload, grade: grade)
        expect(delete :destroy, params: { grade_id: grade.id, id: file_upload.id }, format: :json).to redirect_to(:root)
      end
    end
  end
end
