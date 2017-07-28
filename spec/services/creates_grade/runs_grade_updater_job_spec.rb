describe Services::Actions::RunsGradeUpdaterJob do
  let(:grade) { build :grade }
  let(:context) { { grade: grade, run_jobs: true } }

  it "expects grade passed to service" do
    expect { described_class.execute({ run_jobs: true })}.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects a confirmation boolean" do
    expect { described_class.execute({ grade: grade })}.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  context "wihout confirmation" do
    let(:grade) { build :student_visible_grade}
    let(:context) { { grade: grade, run_jobs: false } }

    it "does not equeue the grade updater job" do
      expect_any_instance_of(GradeUpdaterJob).to_not receive(:enqueue)
      described_class.execute context
    end
  end

  context "with grade not student visible" do

    it "does not enqueue the grade updater job" do
      expect_any_instance_of(GradeUpdaterJob).to_not receive(:enqueue)
      described_class.execute context
    end
  end

  context "with grade student visible" do
    let(:grade) { build :student_visible_grade}

    it "enqueues the grade updater job" do
      expect_any_instance_of(GradeUpdaterJob).to receive(:enqueue)
      described_class.execute context
    end
  end
end
