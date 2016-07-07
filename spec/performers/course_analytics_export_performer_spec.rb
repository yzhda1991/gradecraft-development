# there's a lot going on in this performer right now since we're refactoring
# the export process itself in another branch, so let's just include the Rails
# spec helper for now and we can pare this down later when we've extracted some
# of the other behavior that's dependent on said helper
#
require "rails_spec_helper"

describe CourseAnalyticsExportPerformer do
  subject { described_class.new export_id: export.id }

  let(:export) { create :course_analytics_export }

  it "has some readable attributes" do
    expect(subject.export).to eq export
    expect(subject.course).to eq export.course
    expect(subject.professor).to eq export.professor
  end

  describe "#setup" do
    # note that #setup is called whenever a descendant of ResqueJob::Performer
    # is instantiated, so just building a new subject here will automatically
    # call setup for us unless we expressly call skip_setup: true in the attrs

    it "finds the export by id and assigns it to @export" do
      subject
      expect(subject.export).to eq export
    end

    it "assigns some export attributes to the performer" do
      subject
      expect(subject.course).to eq export.course
      expect(subject.professor).to eq export.professor
    end

    it "updates the export started time" do
      expect_any_instance_of(export.class).to receive(:update_export_started_time)
      subject
    end
  end
end
