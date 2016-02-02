require 'rails_spec_helper'

RSpec.describe UploadsController do
  let(:controller_instance) { UploadsController.new }

  describe "#remove" do
    subject { get :remove }
    it "fetches the upload" do
      expect(controller).to receive(:fetch_upload)
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
  end
end
