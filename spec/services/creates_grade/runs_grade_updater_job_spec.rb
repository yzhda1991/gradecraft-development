describe Services::Actions::RunsGradeUpdaterJob do
  let(:grade) { build :grade }
  let(:update_grade) { true }
  let(:context) { { grade: grade, update_grade: update_grade } }

  it "expects grade passed to service" do
    expect { described_class.execute({ update_grade: update_grade })}.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects update grade" do
    expect { described_class.execute({ grade: grade })}.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  context "with update grade equal to false" do
    let(:update_grade) { false }

    it "does not enqueue the grade updater job" do
      expect_any_instance_of(GradeUpdaterJob).to_not receive(:enqueue)
      described_class.execute context
    end
  end

  context "with update grade equal to true" do
    let(:update_grade) { true }

    it "enqueues the grade updater job" do
      expect_any_instance_of(GradeUpdaterJob).to receive(:enqueue)
      described_class.execute context
    end
  end
end
