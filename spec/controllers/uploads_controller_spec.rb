require 'rails_spec_helper'

RSpec.describe UploadsController do
  let(:controller_instance) { UploadsController.new }

  describe "#remove" do
    subject { get :remove }
    it "fetches the upload" do
      # expect(controller).to receive(:fetch_upload)
      skip
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
    let(:submission_file) { create(:submission_file) }

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
end
