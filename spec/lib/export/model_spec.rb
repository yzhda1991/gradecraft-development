require "active_record_spec_helper"
require "./app/models/course_analytics_export"
require_relative "../../support/uni_mock/rails"

describe Export::Model do
  include UniMock::StubRails

  # test a class that is actually using this module
  describe CourseAnalyticsExport do

    describe "#downloadable?" do
      let(:result) { subject.downloadable? }

      context "export has a last_export_completed_at time" do
        it "is downloadable" do
          subject.last_export_completed_at = Time.now
          expect(result).to be_truthy
        end
      end

      context "export doesn't have a last_export_completed_at time" do
        it "isn't download able" do
          subject.last_export_completed_at = nil
          expect(result).to be_falsey
        end
      end
    end

    describe "#update_export_completed_time" do
      let(:time_now) { Date.parse("Oct 20 1999").to_time }

      it "updates the last_export_completed_at time to now" do
        allow(Time).to receive(:now) { time_now }
        subject.update_export_completed_time
        expect(subject.last_export_completed_at).to eq(time_now)
      end
    end

    describe "#created_at_date" do
      subject { create :course_analytics_export }
      let(:result) { subject.created_at_date }

      context "created_at is present" do
        it "formats the created_at date" do
          expect(result).to eq subject.created_at.strftime("%F")
        end
      end

      context "created_at is nil" do
        it "returns nil" do
          allow(subject).to receive(:created_at) { nil }
          expect(result).to be_nil
        end
      end
    end

    describe "#created_at_in_microseconds" do
      subject { create :course_analytics_export }
      let(:result) { subject.created_at_in_microseconds }

      context "created_at is present" do
        it "formats the created_at time in microseconds" do
          expect(result).to eq subject.created_at.to_f.to_s.delete(".")
        end
      end

      context "created_at is nil" do
        it "returns nil" do
          allow(subject).to receive(:created_at) { nil }
          expect(result).to be_nil
        end
      end
    end

    describe "#update_export_completed_time" do
      let(:result) { subject.update_export_completed_time }
      let(:sometime) { Date.parse("Oct 20 1982").to_time }

      before { allow(Time).to receive(:now) { sometime } }

      it "calls update_attributes on the submissions export with the export time" do
        expect(subject).to receive(:update_attributes)
          .with(last_export_completed_at: sometime)
        result
      end

      it "updates the last_export_completed_at timestamp to now" do
        result
        expect(subject.last_export_completed_at).to eq(sometime)
      end
    end
  end
end
