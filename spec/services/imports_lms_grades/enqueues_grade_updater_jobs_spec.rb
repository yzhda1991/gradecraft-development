require "rails_spec_helper"
require "./app/services/imports_lms_grades/enqueues_grade_updater_jobs"

describe Services::Actions::EnqueuesGradeUpdaterJobs do
  let(:first_grade) { create :grade, status: "Graded" }
  let(:second_grade) { create :grade, status: "Graded" }
  let(:grades_import_result) { double(:result, successful: [first_grade, second_grade ]) }

  before { allow_any_instance_of(GradeUpdaterJob).to receive(:enqueue) }

  it "expects grade import results" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "enqueues the grade updater job for all sucessful imported grades" do
    expect(GradeUpdaterJob).to receive(:new).with(grade_id: first_grade.id).and_call_original
    expect(GradeUpdaterJob).to receive(:new).with(grade_id: second_grade.id).and_call_original

    described_class.execute grades_import_result: grades_import_result
  end

  it "does not enqueue in progress grades" do
    unreleased_grade = create :grade, status: "In Progress"
    allow(grades_import_result).to receive(:successful).and_return [unreleased_grade]

    expect(GradeUpdaterJob).to_not receive(:new).with(grade_id: second_grade.id)

    described_class.execute grades_import_result: grades_import_result
  end

  it "does not enqueue grades that are not visible to the student" do
    allow_any_instance_of(GradeProctor).to receive(:viewable?).and_return false

    expect(GradeUpdaterJob).to_not receive(:new)

    described_class.execute grades_import_result: grades_import_result
  end
end
