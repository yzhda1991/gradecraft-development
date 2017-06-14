describe Services::Actions::SavesGrade do
  let(:grade) { build :grade }
  let(:previous_changes_with_raw_points) { { raw_points: 100 } }
  let(:previous_changes_without_raw_points) { { raw_points: nil } }

  it "expects grade passed to service" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "saves the grades" do
    result = described_class.execute grade: grade
    expect(result[:grade]).to_not be_new_record
  end

  it "promises update grade" do
    result = described_class.execute grade: grade
    expect(result).to have_key :update_grade
  end

  it "halts if a record is invalid" do
    grade.student_id = nil
    expect { described_class.execute grade: grade }.to \
      raise_error LightService::FailWithRollbackError
  end

  context "when the grade has not been graded or released" do
    before(:each) { allow_any_instance_of(GradeStatus).to receive(:student_visible?).and_return false }

    context "with previous changes to raw points" do
      it "sets update grade to false" do
        allow_any_instance_of(Grade).to receive(:previous_changes).and_return previous_changes_with_raw_points
        result = described_class.execute grade: grade
        expect(result.update_grade).to be_falsey
      end
    end

    context "with no previous changes to raw points" do
      it "sets update grade to false" do
        allow_any_instance_of(Grade).to receive(:previous_changes).and_return previous_changes_without_raw_points
        result = described_class.execute grade: grade
        expect(result.update_grade).to be_falsey
      end
    end
  end

  context "when the grade has been graded or released" do
    before(:each) { allow_any_instance_of(GradeStatus).to receive(:student_visible?).and_return true }

    context "with previous changes to raw points" do
      it "sets update grade to true" do
        allow_any_instance_of(Grade).to receive(:previous_changes).and_return previous_changes_with_raw_points
        result = described_class.execute grade: grade
        expect(result.update_grade).to be_truthy
      end
    end

    context "with no previous changes to raw points" do
      it "sets update grade to false" do
        allow_any_instance_of(Grade).to receive(:previous_changes).and_return previous_changes_without_raw_points
        result = described_class.execute grade: grade
        expect(result.update_grade).to be_falsey
      end
    end
  end
end
