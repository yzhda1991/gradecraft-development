require 'spec_helper'

RSpec.describe InfoController, type: :controller do
  include InQueueHelper

  let(:course) { create(:course_accepting_groups) }
  let(:professor) do 
    professor = create(:user)
    professor.courses << course
    professor
  end

  before do
    ResqueSpec.reset!
    login_user(professor)
    session[:course_id] = course.id
  end

  describe "#gradebook" do
    let(:job_double) { double(GradebookExporterJob) }

    it "redirects" do # add this just to ensure that the action is completing
      pending
    end

    it "creates calls #new on GradebookExporterJob" do
      expect(GradebookExporterJob).to respond_to(:new).with(1).argument
      get :gradebook
    end

    it "creates a new GradebookExporterJob" do
      get :gradebook
      pp assigns
      expect(assigns(:gradebook_exporter_job).class).to eq(GradebookExporterJob) 
      expect(assigns(:gradebook_exporter_job).attrs).to eq({user_id: professor.id, course_id: course.id})
    end

    it "triggers the enqueue on the new job" do
      get :gradebook
      expect(assigns(:gradebook_exporter_job)).to receive(:enqueue)
    end
  end
end
