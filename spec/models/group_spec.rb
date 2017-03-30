describe Group do

  let(:group) { create(:group, name: "Steven's Wondersauce") }

  describe "proposal sanitization" do
    it "has html save text text_proposal" do
      group.text_proposal = "Fine & Dandy"
      group.save
      expect(group.text_proposal).to eq("Fine &amp; Dandy")
    end
  end

  describe "validations" do
    it "is valid with a name and an approval state" do
      expect(group).to be_valid
    end

    it "is invalid without a name" do
      group.name = nil
      expect(group).to be_invalid
    end

    it "is invalid without an approval state" do
      group.approved = nil
      expect(group).to be_invalid
    end

    it "does not allow more group members than the assignment max" do
      student1 = create :user
      student2 = create :user
      student3 = create :user
      student4 = create :user
      student5 = create :user
      assignment1 = create :assignment, max_group_size: 4

      group.assignments << assignment1
      group.students << [student1, student2, student3, student4, student5]

      expect(group).to be_invalid
    end

    it "does not allow fewer group members than the assignment min" do
      student1 = create :user
      student2 = create :user
      assignment1 = create :assignment, max_group_size: 4

      group.assignments << assignment1
      group.students << [student1, student2]

      expect(group).to be_invalid
    end

    it "does not allow students to belong to more than one group per assignment" do
      student1 = create :user
      student2 = create :user
      student3 = create :user
      assignment1 = create :assignment, max_group_size: 2
      group_dup = create :group
      group_dup.assignments << assignment1
      group_dup.students << [student1, student3]
      group.assignments << assignment1
      group.students << [student1, student2]

      expect(group).to be_invalid
    end

    it "requires the group to work on at least one assignment" do
      student1 = create :user
      student2 = create :user
      assignment1 = create :assignment, max_group_size: 4

      group.students << [student1, student2]

      expect(group).to be_invalid
    end
  end

  describe "#approved?" do
    it "returns true if approved" do
      group.approved = "Approved"
      expect(group.approved?).to eq true
    end

    it "returns false if any other state" do
      group.approved = "Rejected"
      expect(group.approved?).to eq false
    end
  end

  describe "#assignment_ids" do
    let(:assignment1) { create :assignment }
    let(:assignment2) { create :assignment }
    let(:student) { create :user }

    it "creates assignment groups for each assignment id" do
      group.assignment_ids = [assignment1, assignment2].map(&:id)
      group.save

      expect(group.assignment_groups.count).to eq 2
    end
  end

  describe "submitter directory names" do
    describe "#submitter_directory_name" do
      it "formats the submitter name into a directory name" do
        expect(group.submitter_directory_name).to eq("Stevens Wondersauce")
      end
    end

    describe "#submitter_directory_name_with_suffix" do
      it "formats the submitter name into a directory name with unique id" do
        expect(group.submitter_directory_name_with_suffix)
          .to eq("Stevens Wondersauce - #{group.id}")
      end
    end
  end

  describe "#grade_for_assignment" do
    context "group grade exists" do
      it "returns the grade" do
        assignment = create :assignment
        group = create :group
        grade = create :grade, group: group, assignment: assignment

        expect(group.grade_for_assignment(assignment)).to eq grade
      end
    end

    context "no group grade exists" do
      it "builds a new grade" do
        assignment = create :assignment
        group = create :group

        grade = group.grade_for_assignment(assignment)

        expect(grade.new_record?).to eq true
        expect(grade.group).to eq group
        expect(grade.assignment).to eq assignment
      end
    end
  end

  describe "#pending?" do
    it "returns true if pending" do
      group.approved = "Pending"
      expect(group.pending?).to eq true
    end

    it "returns false if any other state" do
      group.approved = "Rejected"
      expect(group.pending?).to eq false
    end
  end

  describe "#rejected?" do
    it "returns true if rejected" do
      group.approved = "Rejected"
      expect(group.rejected?).to eq true
    end

    it "returns false if any other state" do
      group.approved = "Approved"
      expect(group.rejected?).to eq false
    end
  end

  describe "#submission_for_assignment(assignment)" do
    let(:assignment) { create(:assignment, grade_scope: "Group") }

    context "when there is not a draft submission" do
      it "returns the group's submission for an assignment" do
        submission = create(:group_submission, group: group, assignment: assignment)
        expect(group.submission_for_assignment(assignment)).to eq(submission)
      end

      it "returns nil if the group doesn't have an assignment submission" do
        # assignment = create(:assignment, grade_scope: "Group")
        expect(group.submission_for_assignment(assignment)).to eq nil
      end
    end

    context "when there is a draft submission" do
      let!(:draft_submission) { create(:group_submission, assignment: assignment, group: group, submitted_at: nil) }

      it "returns nil if submitted only is true" do
        expect(group.submission_for_assignment(assignment)).to eq nil
      end

      it "returns the draft submission" do
        expect(group.submission_for_assignment(assignment, false)).to eq draft_submission
      end
    end
  end

  describe "#same_name_as?" do
    let(:hound_dogz1) { create(:group, name: "Hound Dogz") }
    let(:hound_dogz2) { create(:group, name: "Hound Dogz") }
    let(:roger_daltry) { create(:group, name: "Roger Daltry") }

    context "has the same name as the group given" do
      it "returns true" do
        expect(hound_dogz1.same_name_as?(hound_dogz2)).to eq true
      end
    end

    context "has a different name than the group given" do
      it "returns false" do
        expect(hound_dogz1.same_name_as?(roger_daltry)).to eq false
      end
    end
  end

end
