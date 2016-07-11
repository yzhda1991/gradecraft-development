require "active_record_spec_helper"
require "showtime"
require "./app/presenters/course_analytics_exports/base"
require "./app/background_jobs/course_analytics_export_job"

describe Presenters::CourseAnalyticsExports::Base do
  subject { described_class.new params: params }

  let(:export) { create :course_analytics_export }
  let(:course) { export.course }
  let(:professor) { export.professor }

  let(:params) do
    { id: export.id }
  end

  it "has a resource name" do
    expect(subject.resource_name).to eq "course analytics export"
  end

  describe "#create_and_enqueue_export" do
    context "export is created" do
      it "creates the export and enqueues the job" do
        allow(subject).to receive(:create_export) { true }
        expect(subject).to receive_message_chain :export_job, :enqueue
        subject.create_and_enqueue_export
      end
    end

    context "export does not create" do
      it "fails and doesn't enqueue a job" do
        allow(subject).to receive(:create_export) { false }
        expect(subject).not_to receive :export_job
        subject.create_and_enqueue_export
      end
    end
  end

  describe "#create_export" do
    before do
      allow(subject).to receive_messages \
        current_user: professor,
        current_course: course
    end

    it "creates a new export and sets it to @export" do
      expect(CourseAnalyticsExport).to receive(:create)
        .with course_id: course.id, professor_id: professor.id
      subject.create_export
    end

    it "sets the export to @export" do
      export = subject.create_export
      expect(subject.instance_variable_get :@export).to eq export
    end
  end

  describe "#export_job" do
    it "builds a new export job" do
      expect(CourseAnalyticsExportJob).to receive(:new)
        .with export_id: export.id
      subject.export_job
    end

    it "caches the export job" do
      export_job = subject.export_job
      expect(subject.instance_variable_get :@export_job).to eq export_job

      # now that we've built one, we shouldn't be building another one
      expect(CourseAnalyticsExportJob).not_to receive(:create)
      subject.export_job
    end
  end

  describe "#export" do
    it "finds the export by id" do
      export # cache the export so it's findable
      expect(subject.export).to eq export
    end

    it "caches the found export" do
      found_export = subject.export
      expect(subject.instance_variable_get :@export).to eq found_export
    end
  end

  describe "#destroy_export" do
    before(:each) do
      # :each also caches the export so we can work with it later
      allow(export).to receive(:delete_object_from_s3) { "whtevrz" }
    end

    context "the export is successfully destroyed" do
      before(:each) do
        allow(export).to receive(:destroy) { true }
      end

      it "returns the output of export.destroy" do
        # then, let's hope that the export can destroy normally on its own
        expect(subject.destroy_export).to eq true
      end

      it "deletes the object from s3" do
        expect(export).to receive(:delete_object_from_s3)
        export.destroy_export
      end
    end

    context "the export is not destroyed" do
      before(:each) do
        # :each also caches the export so we can work with it later
        allow(export).to receive(:destroy) { false }
      end

      it "returns false" do
        expect(subject.destroy_export).to eq false
      end

      it "doesn't delete the object from s3" do
        expect(export).not_to receive(:delete_object_from_s3)
        subject.destroy_export
      end
    end
  end

  describe "#course" do
  end

  describe "#stream_export" do
  end
end
