require "light-service"
require "active_record_spec_helper"
require "./app/services/creates_grade/runs_grade_updater_job"

describe Services::Actions::RunsGradeUpdaterJob do
  let(:grade) { build :grade }
  let(:student_visible_status) { true }
  let(:context)  {{ grade: grade, student_visible_status: student_visible_status }}

  it "expects grade passed to service" do
    expect { described_class.execute({ student_visible_status: student_visible_status })}.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

    it "expects student visible status passed to service" do
    expect { described_class.execute({ grade: grade })}.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "enqueues the grade updater job" do
    expect_any_instance_of(GradeUpdaterJob).to receive(:enqueue)
    described_class.execute context
  end
end
