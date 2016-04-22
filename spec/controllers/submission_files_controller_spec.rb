require "rails_spec_helper"

describe SubmissionFilesController do
  let(:course) { Course.last }
  let(:student) { User.last }
  let(:submission_file) { create(:submission_file) }
  let(:submission) { submission_file.submission }

  before do
    create(:course)
    create(:user)
  end

  before(:each) do
    session[:course_id] = course.id
  end

  context "user is authorized" do
    let(:professor) { User.last }
    let(:course_membership) { CourseMembership.last }

    before do
      create(:course_membership,
        user: professor,
        course: course,
        role: "professor"
      )
    end

    before(:each) do
      login_user professor
    end

    describe "GET download" do
      let(:result) { get :download, params }
      let(:params) { { id: submission_file.id, index: 20 } }

      it "builds a new SubmissionFilesPresenter with the params" do
        expect(SubmissionFilesPresenter).to receive(:new).with request.params
        result
      end

      context "user is authorized to read the submission" do
        context "the submission file is streamable" do
          it "streams the submission file with the filename" do
          end
        end

        context "the submission file is not streamable" do
        end
      end

      context "user is not authorized to read the submission" do
        context "
      end
    end
  end
end
