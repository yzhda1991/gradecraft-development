require 'spec_helper'

RSpec.describe InfoController, type: :controller, background_job: true do
  include InQueueHelper

  let(:course) { create(:course_accepting_groups) }
  let(:professor) { create(:user) }
  let(:enroll_professor) { CourseMembership.create(job_attributes.merge(role: "professor")) }
  let(:job_attributes) {{user_id: professor.id, course_id: course.id }}

  before do
    enroll_professor
    login_user(professor)
    session[:course_id] = course.id
  end

  before(:each) { ResqueSpec.reset! }

  describe "#gradebook" do
    it "increases the queue size by one" do
      expect{ get :gradebook }.to change { queue(GradebookExporterJob).size }.by(1)
    end

    it "queues the job" do
      get :gradebook
      expect(GradebookExporterJob).to have_queued(job_attributes)
    end

    it "creates calls #new on GradebookExporterJob" do
      expect(GradebookExporterJob).to respond_to(:new).with(1).argument
      get :gradebook
    end

    it "creates a new GradebookExporterJob" do
      get :gradebook
      expect(assigns(:gradebook_exporter_job).class).to eq(GradebookExporterJob)
    end
  end

  describe "#research_gradebook" do
    it "increases the queue size by one" do
      expect{ get :research_gradebook }.to change { queue(GradeExportJob).size }.by(1)
    end

    it "queues the job" do
      get :research_gradebook
      expect(GradeExportJob).to have_queued(job_attributes)
    end

    it "creates calls #new on GradeExportJob" do
      expect(GradeExportJob).to respond_to(:new).with(1).argument
      get :research_gradebook
    end

    it "creates a new GradeExportJob" do
      get :research_gradebook
      expect(assigns(:grade_export_job).class).to eq(GradeExportJob)
    end
  end
end
