require 'rails_spec_helper'

RSpec.describe UploadsController do
  let(:controller_instance) { UploadsController.new }
  let(:submission_file) { create(:submission_file) }
  let(:course) { create(:course) }
  let(:student) { create(:user) }
  let(:create_student_course_membership) { CourseMembership.create user: student, course: create(:course), role: "student" }
  let(:stub_submission_file) { allow(SubmissionFile).to receive(:find).with(submission_file.id) { submission_file }}

  before(:each) do
    create_student_course_membership
    login_user(student)
    stub_submission_file
  end

  describe "#remove" do
    subject { get :remove, model: "SubmissionFile", upload_id: submission_file.id }
    before(:each) { request.env['HTTP_REFERER'] = 'localhost:8000' }

    it "fetches the upload" do
      controller.instance_variable_set(:@upload, submission_file)
      expect(controller).to receive(:fetch_upload_with_model)
      subject
    end

    it "deletes the upload from s3" do
      expect(submission_file).to receive(:delete_from_s3)
      subject
    end

    it "sets the upload to an ivar" do
      subject
      expect(assigns(:upload)).to eq(submission_file)
    end
    
    it "redirects back to where you were" do
      subject
      expect(response).to redirect_to("localhost:8000")
    end

    context "upload was successfully deleted from s3" do
      before { allow(submission_file).to receive(:exists_on_s3?) { false }}
      it "destroys the upload" do
        expect(submission_file).to receive(:destroy)
        subject
      end

      it "destroys the upload with flash" do
        expect(controller).to receive(:destroy_upload_with_flash)
        subject
      end
    end

    context "upload failed to delete from s3" do
      before { allow(submission_file).to receive(:exists_on_s3?) { true }}
      it "sets a flash alert" do
        subject
        expect(flash[:alert]).to match(/File failed to delete from the server/)
      end
    end
  end

  describe "#upload_klass" do
    subject { controller_instance.instance_eval { upload_klass } }
    before { allow(controller_instance).to receive(:params) { model_params }}

    context "model is passed in camelcased format" do
      let(:model_params) { ActionController::Parameters.new model: "SubmissionFile" }
      it "returns the upload klass" do
        expect(subject).to eq(SubmissionFile)
      end
    end

    context "model is passed in underscored format" do
      let(:model_params) { ActionController::Parameters.new model: "submission_file" }
      it "still returns the upload klass" do
        expect(subject).to eq(SubmissionFile)
      end
    end
  end

  describe "#destroy_upload_with_flash" do
    subject { controller_instance.instance_eval { destroy_upload_with_flash } }

    before(:each) do
      controller_instance.request = ActionDispatch::Request.new('rack.input' => [])
      controller_instance.instance_variable_set(:@upload, submission_file)
    end

    it "destroys the upload" do
      expect(submission_file).to receive(:destroy)
      subject
    end

    context "upload destroys successfully" do
      before { allow(submission_file).to receive(:destroy) { true }}
      it "sets a success message" do
        subject
        expect(controller_instance.flash[:success]).to match(/File was successfully removed/)
      end
    end

    context "upload fails to destroy" do
      before { allow(submission_file).to receive(:destroy) { false }}
      it "sets an alert message" do
        subject
        expect(controller_instance.flash[:alert]).to match(/File was deleted/)
      end
    end
  end

  describe "#fetch_upload_with_model" do
    let(:upload_params) { ActionController::Parameters.new upload_id: submission_file.id }

    subject { controller_instance.instance_eval { fetch_upload_with_model } }

    before(:each) do
      controller_instance.instance_variable_set(:@upload, submission_file)
      allow(controller_instance).to receive(:upload_klass) { SubmissionFile }
      allow(controller_instance).to receive(:params) { upload_params }
    end

    it "fetches the upload" do
      expect(SubmissionFile).to receive(:find).with(submission_file.id)
      subject
    end

    it "sets an @upload ivar" do
      subject
      expect(controller_instance.instance_variable_get(:@upload)).to eq(submission_file)
    end
  end
end
