describe Submissions::Presenter do
  subject do
    described_class.new assignment_id: assignment.id,
                        group_id: group.id,
                        course: course
  end

  let(:course) { double(:course, assignments: assignments, groups: groups) }
  let(:assignment) { double(:assignment, id: 123) }
  let(:group) { double(:group, id: 765) }
  let(:assignments) { double(:active_record_relation).as_null_object }
  let(:groups) { double(:active_record_relation).as_null_object }

  describe "#assignment" do
    let(:result) { subject.assignment }

    before do
      allow(assignments).to receive(:find).with(assignment.id) { assignment }
    end

    it "returns the assignment with the given id" do
      expect(subject.assignment).to eq assignment
    end

    it "caches the assignment" do
      result
      expect(assignments).not_to receive(:find).with assignment.id
      result
    end

    it "sets the assignment to @assignment" do
      result
      expect(subject.instance_variable_get(:@assignment)).to eq assignment
    end
  end

  describe "#course" do
    it "is the course that is passed in as a property" do
      expect(subject.course).to eq course
    end
  end

  describe "#group" do
    let(:result) { subject.group }

    before do
      allow(groups).to receive(:find).with(group.id) { group }
    end

    it "is nil if the assignment does not allow groups" do
      allow(subject).to receive(:assignment) { assignment }
      allow(assignment).to receive(:has_groups?) { false }
      expect(result).to eq nil
    end

    it "returns the group" do
      expect(result).to eq group
    end

    it "caches the group" do
      result
      expect(assignments).not_to receive(:find).with assignment.id
      result
    end

    it "sets the group to @group" do
      result
      expect(subject.instance_variable_get(:@group)).to eq group
    end
  end

  describe "#submission_will_be_late?" do
    let(:now) { DateTime.now }

    before(:each) do
      allow(assignments).to receive(:find).with(assignment.id) { assignment }
    end

    context "when the assignment has a due_at value" do
      context "with the current time being after the due_at time" do
        it "returns true" do
          allow(assignment).to receive(:due_at).and_return (now - 1)
          expect(subject.submission_will_be_late?).to eq true
        end
      end

      context "with the current time being before the due_at time" do
        it "returns false" do
          allow(assignment).to receive(:due_at).and_return (now + 1)
          expect(subject.submission_will_be_late?).to eq false
        end
      end
    end

    context "when the assignment does not have a due_at value" do
      it "returns false" do
        allow(assignment).to receive(:due_at).and_return nil
        expect(subject.submission_will_be_late?).to eq false
      end
    end
  end
end
