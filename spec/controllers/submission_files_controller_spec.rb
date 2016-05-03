require "rails_spec_helper"

describe SubmissionFilesController do
  let(:course) { Course.last }
  let(:student) { User.last }
  let(:submission_file) { create(:submission_file) }
  let(:submission) { submission_file.submission }
  let(:ability) { Object.new.extend(CanCan::Ability) }

  before do
    create(:course)
    create(:user)
  end

  before(:each) do
    session[:course_id] = course.id
  end

  context "user is authorized" do
    let(:course_membership) { CourseMembership.last }

    before do
      create(:course_membership,
        user: student,
        course: course,
        role: "student"
      )
    end

    before(:each) do
      login_user student
    end


    describe "GET download" do
      let(:result) { get :download, params }
      let(:params) { { id: submission_file.id, index: 20 } }
      let(:presenter) { SubmissionFilesPresenter.new params: params }

      before do
        allow(controller).to receive_messages(
          presenter: presenter,
          current_ability: ability
        )

        allow(presenter).to receive_messages(
          submission_file_streamable?: true,
          stream_submission_file: "file-data",
          filename: "filename.xyz",
          submission: submission,
          submission_file: submission_file
        )

        ability.can :download, submission_file
      end

      describe "#presenter" do
        let(:result) { controller.presenter }

        before do
          allow(controller).to receive(:params) { params }
        end

        it "builds a new SubmissionFilesPresenter with the params" do
          expect(SubmissionFilesPresenter).to receive(:new)
          result
        end
      end

      context "user is authorized to read the submission" do
        context "the submission file is streamable" do
          it "streams the submission file with the filename" do
            expect(controller).to receive(:send_data)
              .with("file-data", filename: "filename.xyz")
            result
          end
        end

        context "the submission file is not streamable" do
          before do
            allow(presenter).to receive(:submission_file_streamable?) { false }
            allow(request).to receive(:referrer) { "http://some-referrer.com" }
          end

          it "marks the submission_file_missing" do
            expect(presenter).to receive(:mark_submission_file_missing)
            result
          end

          it "returns a flash alert saying the file was not found" do
            result
            expect(controller.flash[:alert])
              .to match(/requested file was not found/)
          end

          it "redirects to the referrer" do
            result
            expect(response).to redirect_to "http://some-referrer.com"
          end
        end
      end

      context "user is not authorized to read the submission" do
        before { ability.cannot :download, submission_file }

        it "raises an Access Denied error" do
          expect { result }.to raise_error(CanCan::AccessDenied)
        end
      end
    end
  end
end
