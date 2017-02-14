require "spec_helper"

describe GradesHelper do
  let(:course) { create :course }

  describe "#in_progress_grades_count_for" do
    let!(:grade) { create :grade, status: "In Progress", course: course }

    it "returns the number of grades that are in progress" do
      expect(in_progress_grades_count_for(course)).to eq 1
    end

    it "caches the result" do
      expect(course).to receive(:grades).and_call_original.at_most(:twice)
      in_progress_grades_count_for(course)
      in_progress_grades_count_for(course)
      Rails.cache.delete in_progress_grades_count_cache_key(course)
      in_progress_grades_count_for(course)
    end
  end

  describe "#unreleased_grades_count_for" do
    let(:assignment) { create :assignment, course: course, release_necessary: true }
    let!(:grade) { create :grade, status: "Graded", assignment: assignment, course: course }

    it "returns the number of grades that are unreleased" do
      expect(unreleased_grades_count_for(course)).to eq 1
    end

    it "caches the result" do
      expect(course).to receive(:grades).and_call_original.at_most(:twice)
      unreleased_grades_count_for(course)
      unreleased_grades_count_for(course)
      Rails.cache.delete unreleased_grades_count_cache_key(course)
      unreleased_grades_count_for(course)
    end
  end

  describe "#grading_status_count_for" do
    class Helper
      include GradesHelper
    end

    let(:helper) { Helper.new }

    it "returns the sum of unreleased grades, in progress grades, and ungraded submissions" do
      allow(helper).to receive(:ungraded_submissions_count_for).with(course).and_return 10
      allow(helper).to receive(:unreleased_grades_count_for).with(course).and_return 20
      allow(helper).to receive(:in_progress_grades_count_for).with(course).and_return 30
      allow(helper).to receive(:resubmission_count_for).with(course).and_return 2
      expect(helper.grading_status_count_for(course)).to eq 62
    end
  end
end
