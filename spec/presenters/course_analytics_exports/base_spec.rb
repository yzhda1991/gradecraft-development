require "active_record_spec_helper"
require "showtime"
require "./app/presenters/course_analytics_exports/base"

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
      export = subject.create_export
      expect(export.class).to eq CourseAnalyticsExport
      expect(export.course_id).to eq course.id
      expect(export.professor_id).to eq professor.id
      expect(export.valid?).to be_truthy
      expect(subject.instance_variable_get :@export).to eq export
    end
  end

  describe "#export_job" do
  end

  describe "#export" do
  end

  describe "#destroy_export" do
  end

  describe "#course" do
  end

  describe "#stream_export" do
  end
end
