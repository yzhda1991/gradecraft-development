describe Services::Actions::RunsGradeUpdaterJob do
  let(:grade) { build :grade }
  let(:update_grade) { true }
  let(:student_visible_status) { true }
  let(:context) { { grade: grade, update_grade: update_grade, student_visible_status: student_visible_status } }

  it "expects grade passed to service" do
    expect { described_class.execute({ update_grade: update_grade, student_visible_status: student_visible_status })}.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects update grade" do
    expect { described_class.execute({ grade: grade, student_visible_status: student_visible_status })}.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects student visible status passed to service" do
    expect { described_class.execute({ grade: grade, update_grade: update_grade })}.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  context "when the grade is viewable" do
    before(:each) { allow_any_instance_of(GradeProctor).to receive(:viewable?).and_return true }

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

  context "when the grade is not viewable" do
    let(:student_visible_status) { false }

    context "with update grade equal to false" do
      let(:update_grade) { false }

      it "does not enqueue the grade updater job" do
        expect_any_instance_of(GradeUpdaterJob).to_not receive(:enqueue)
        described_class.execute context
      end
    end

    context "with update grade equal to true" do
      let(:update_grade) { true }

      it "does not enqueue the grade updater job" do
        expect_any_instance_of(GradeUpdaterJob).to_not receive(:enqueue)
        described_class.execute context
      end
    end
  end
end
