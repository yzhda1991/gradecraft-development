require "active_record_spec_helper"
require "toolkits/sanitization_toolkit"

describe Group, focus: true do
  let(:assignment) { create :assignment, max_group_size: 4 }
  subject { create(:group, assignment: assignment ) }

  it_behaves_like "a model that needs sanitization", :text_proposal

  describe "validations" do
    it "is valid with a name and an approval state" do
      expect(subject).to be_valid
    end

    it "is invalid without a name" do
      subject.name = nil
      expect(subject).to be_invalid
    end

    it "is invalid without an approval state" do
      subject.approved = nil
      expect(subject).to be_invalid
    end

    it "does not allow more group members than the course max" do
      skip "implement"
    end

    it "does not allow fewer group members than the course min" do
      skip "implement"
    end

    it "does not allow students to belong to more than one group per assignment" do
      skip "implement"
    end

    it "requires the group to work on at least one assignment" do
      skip "implement"
    end
  end

  describe "#approved?" do
    it "returns true if approved" do
      subject.approved = "Approved"
      expect(subject.approved?).to eq true
    end

    it "returns false if any other state" do
      subject.approved = "Rejected"
      expect(subject.approved?).to eq false
    end
  end

  describe "#pending?" do
    it "returns true if pending" do
      subject.approved = "Pending"
      expect(subject.pending?).to eq true
    end

    it "returns false if any other state" do
      subject.approved = "Rejected"
      expect(subject.pending?).to eq false
    end
  end

  describe "#rejected?" do
    it "returns true if rejected" do
      subject.approved = "Rejected"
      expect(subject.rejected?).to eq true
    end

    it "returns false if any other state" do
      subject.approved = "Approved"
      expect(subject.rejected?).to eq false
    end
  end

  describe "#submission_for_assignment(assignment)" do
    it "returns the group's submission for an assignment" do
      assignment = create(:assignment, grade_scope: "Group")
      submission = create(:submission, group: subject, assignment: assignment)
      expect(subject.submission_for_assignment(assignment)).to eq(submission)
    end

    it "returns nil if the group doesn't have an assignment submission" do
      assignment = create(:assignment, grade_scope: "Group")
      expect(subject.submission_for_assignment(assignment)).to eq(nil)
    end
  end

end
