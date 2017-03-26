describe Submission do
  
  let(:course) { build(:course) }
  let(:assignment) { create(:assignment) }
  let(:student) { create(:user) }
  let(:submission) { create(:submission, course: course, assignment: assignment, student: student) }
  let(:ungraded_submission) { create(:submission, course: course) }

  describe "validations" do
    it "is valid" do 
      expect(submission).to be_valid
    end

    it "requires a valid url" do
      submission.link = "not a url"
      expect(submission).to_not be_valid
      expect(submission.errors[:link]).to include "is invalid"
    end

    it "requires something to have been submitted" do
      submission.link = nil
      submission.text_comment = nil
      submission.submission_files.clear
      expect(submission).to_not be_valid
      expect(submission.errors[:base]).to include "Submission cannot be empty"
    end

    it "restricts duplicate submissions for a given student on an assignment" do
      submission = create(:submission)
      expect{create(:submission, assignment: submission.assignment,
        student: submission.student)}.to raise_error ActiveRecord::RecordInvalid,
        /should only have one submission per student or group/
    end

    it "restricts duplicate submissions for a given group on an assignment" do
      submission = create(:group_submission)
      expect{create(:group_submission, assignment: submission.assignment,
        group: submission.group)}.to raise_error ActiveRecord::RecordInvalid,
        /should only have one submission per student or group/
    end

    it "allows multiple group submissions to be created" do
      group = create(:group)
      expect{create_list(:group_submission, 3, group: group)}.not_to raise_error
    end

    it "allows multiple individual submissions to be created" do
      expect{create_list(:submission, 3)}.not_to raise_error
    end

    it "requires either a group id or student id but not both" do
      expect(build_stubbed(:submission)).to be_valid
      expect(build_stubbed(:group_submission)).to be_valid
      expect(build_stubbed(:submission, student: nil, group: nil)).not_to be_valid
      expect(build_stubbed(:submission, student: student, group: build_stubbed(:group))).not_to be_valid
    end
  end

  context "with a persisted assignment" do 
    it_behaves_like "a historical model", :submission, link: "http://example.org"
    it_behaves_like "a model that needs sanitization", :submission, :text_comment
  end

  describe "versioning", versioning: true do
    before { submission.save }

    it "creates a version when the link is updated" do
      previous_link = submission.link
      submission.update_attributes link: "http://example.com"
      expect(submission).to have_a_version_with link: previous_link
    end

    it "creates a version when the attachment is updated" do
      # directly create the submission file with the submission_id to avoid an
      # update action. Creating the submission_file, then updating it with the
      # submission_id requires a create, then an update, which creates two
      # versions instead of one.
      #
      submission.submission_files.create attributes_for(:submission_file)
      expect(submission.submission_files.first.versions.count).to eq 1
    end

    it "creates a version when the comment is updated" do
      previous_comment = submission.text_comment
      submission.update_attributes text_comment: "This was updated"
      expect(submission).to have_a_version_with text_comment: previous_comment
    end
  end

  it "can be saved with only a text comment" do
    submission.text_comment = "I volunteer! I volunteer! I volunteer as tribute!"
    submission.save!
    expect(submission.errors.size).to eq(0)
  end

  it "can be saved with only a link" do
    submission.link = "http://www.amazon.com/dp/0439023521"
    submission.save!
    expect expect(submission.errors.size).to eq(0)
  end

  it "can be saved with only an attached file" do
    submission.submission_files << build(:submission_file)
    submission.save!
    expect expect(submission.errors.size).to eq(0)
  end

  it "can have an an attached file, comment, and link" do
    submission.text_comment = "I volunteer! I volunteer! I volunteer as tribute!"
    submission.link = "http://www.amazon.com/dp/0439023521"
    submission.submission_files << build(:submission_file)
    submission.save!
    expect expect(submission.errors.size).to eq(0)
  end

  describe ".for_course" do
    it "returns all submissions for a specific course" do
      course = create(:course)
      course_submission = create(:submission, course: course)
      another_submission = create(:submission)
      results = Submission.for_course(course)
      expect(results).to eq [course_submission]
    end
  end

  describe ".for_student" do
    it "returns all submissions for a specific student" do
      another_submission = create(:submission)
      results = Submission.for_student(student)
      expect(results).to eq [submission]
    end
  end

  describe ".for_assignment_and_student" do
    it "returns the submission for the student and assignment" do
      expect(Submission.for_assignment_and_student(assignment.id, student.id)).to eq [submission]
    end
  end

  describe ".for_assignment_and_group" do
    let(:group_assignment) { create(:group_assignment) }
    let!(:assignment_group) { create(:assignment_group, assignment: group_assignment) }
    let!(:group_membership) { create(:group_membership, student: student, group: assignment_group.group) }
    let!(:group_submission) { create(:group_submission, assignment: group_assignment, group: assignment_group.group) }

    it "returns the submission for the group and assignment" do
      result = Submission.for_assignment_and_group(group_assignment.id, assignment_group.group_id).first
      expect(result).to eq group_submission
    end
  end

  describe ".submitted" do
    before { Submission.destroy_all }

    it "returns only submissions with a submitted at date" do
      submitted_submission = create(:submission)
      draft_submission = create(:draft_submission)
      expect(Submission.submitted).to eq [submitted_submission]
    end
  end

  describe "#submission_files_attributes=" do
    it "supports multiple file uploads" do
      file_attribute_1 = fixture_file "test_file.txt", "txt"
      file_attribute_2 = fixture_file "test_image.jpg", "image/jpg"
      submission.submission_files_attributes = { "0" => { "file" => [file_attribute_1, file_attribute_2] }}
      expect(submission.submission_files.length).to eq 2
      expect(submission.submission_files[0].filename).to eq "test_file.txt"
      expect(submission.submission_files[1].filename).to eq "test_image.jpg"
    end
  end

  describe "#submitted_this_week" do
    let(:assignment_type) { create(:assignment_type) }
    let(:assignment) { create(:assignment, assignment_type: assignment_type) }
    let!(:submission) { create(:submission, assignment: assignment, submitted_at: DateTime.now - 1.day) }

    it "returns non-draft submissions for the past week" do
      create(:draft_submission, assignment: assignment)
      create(:submission, assignment: assignment, submitted_at: DateTime.now - 8.day)
      result = Submission.submitted_this_week(assignment_type)
      expect(result.count).to eq 1
      expect(result).to include submission
    end
  end

  describe "#graded_at" do
    it "returns when the grade was graded if it was graded" do
      graded_at = DateTime.now
      grade = create(:grade, assignment: assignment, student: student, submission: submission, status: "Graded", graded_at: graded_at)
      expect(submission.graded_at).to eq graded_at
    end

    it "returns nil if there is no grade" do
      expect(submission.graded_at).to be_nil
    end

    it "returns nil if the grade is not released" do
      grade = create(:grade, submission: submission)
      expect(submission.graded_at).to be_nil
    end
  end

  describe "#graded?" do
    it "returns false for a submission that has no grade" do
      expect(submission).to_not be_graded
    end

    it "returns false for a submission that has grade that is not student visible" do
      grade = create(:grade, submission: submission)
      expect(submission).to_not be_graded
    end

    it "returns true for a submission that has grade that is student visible" do
      # because of the way that the submission_grades query is written, we need to create both the assignment and the student for the test to pass 
      grade = create(:grade, assignment: assignment, student: student, submission: submission, status: "Graded")
      expect(submission).to be_graded
    end
  end

  describe "#ungraded?" do
    it "returns false for a submission that has a grade" do
      expect(submission).to be_ungraded
    end

    it "returns true for a submission that has grade but no status" do
      grade = create(:grade, submission: submission)
      expect(submission).to be_ungraded
    end

    it "returns false for a submission that has grade that is student visible" do
      grade = create(:grade, assignment: assignment, student: student, submission: submission, status: "Graded")
      expect(submission).to_not be_ungraded
    end
  end

  describe ".ungraded" do
    let(:in_progress_submission) { create(:submission, course: course) }
    
    it "returns the submissions that do not have any grades" do
      expect(Submission.ungraded).to eq [ungraded_submission]
    end

    it "does not return the submissions that have in progress grades" do
      create :grade, course: course, assignment: in_progress_submission.assignment,
        student: submission.student, submission: in_progress_submission, status: "In Progress"
      expect(Submission.ungraded).to_not include [in_progress_submission]
    end

    it "does not return submissions that have been graded or released" do
      create :grade, course: course, assignment: submission.assignment,
        student: submission.student, submission: submission, status: "Graded"
      expect(Submission.ungraded).to be_empty
    end

    it "returns the group submissions that do not have a grade" do
      group = create :group
      create :grade, course: course, group: group, submission: submission,
        status: "Graded"
      submission.update_attributes group_id: group.id, student_id: nil
      expect(Submission.ungraded).to eq [submission]
    end
  end

  describe ".resubmitted" do
    it "returns the submissions that have been submitted after they were graded" do
      grade = create(:grade, submission: submission, status: "Graded", graded_at: 1.day.ago)
      submission.submitted_at = DateTime.now
      submission.save
      expect(Submission.resubmitted).to eq [submission]
    end

    it "does not return ungraded submissions" do
      create(:grade, submission: submission, graded_at: 1.day.ago)
      submission.submitted_at = DateTime.now
      submission.save
      expect(Submission.resubmitted).to be_empty
    end

    it "does not return submissions that have unreleased grades" do
      assignment = build(:assignment, release_necessary: true)
      submission = build(:submission, assignment: assignment)
      create(:unreleased_grade, submission: submission, graded_at: 1.day.ago)
      submission.submitted_at = DateTime.now
      submission.save
      expect(Submission.resubmitted).to be_empty
    end

    it "does not return resubmissions that have been graded" do
      grade = create(:grade, submission: submission, status: "Graded", graded_at: 1.day.ago)
      submission.submitted_at = 2.days.ago
      submission.save
      expect(Submission.resubmitted).to be_empty
    end

    it "returns one submission for a group resubmissions" do
      submission = build(:group_submission)
      student1 = create(:user)
      student2 = create(:user)
      group = create(:group, assignments: [submission.assignment])
      group.students << [student1, student2]
      grade1 = create(:grade, submission: submission, student: student1,
                      status: "Graded", graded_at: 1.day.ago)
      grade2 = create(:grade, submission: submission, student: student2,
                      status: "Graded", graded_at: 1.day.ago)
      submission.submitted_at = DateTime.now
      submission.group_id = group.id
      submission.save
      expect(Submission.resubmitted).to eq [submission]
    end
  end

  describe ".order_by_submitted" do
    before do
      Submission.delete_all
    end

    it "returns the submissions in the order they were submitted" do
      submitted_yesterday = create(:submission, submitted_at: 1.day.ago)
      never_submitted = create(:submission, submitted_at: nil)
      just_submitted = create(:submission, submitted_at: DateTime.now)
      expect(Submission.order_by_submitted).to eq [submitted_yesterday, just_submitted, never_submitted]
    end
  end

  describe "#will_be_resubmitted?", versioning: true do
    before { submission.save }

    it "returns false if there is no grade" do
      expect(submission).to_not be_will_be_resubmitted
    end

    it "returns true if there is a grade that is visible to the student" do
      create :grade, student: student, status: "Released", submission: submission, assignment: assignment
      expect(submission).to be_will_be_resubmitted
    end
  end

  describe "#resubmitted?" do
    it "returns false if it has no grade" do
      expect(submission).to_not be_resubmitted
    end

    it "returns true if grade was graded before it was submitted" do
      create :grade, status: "Graded", student: student, submission: submission,
        assignment: assignment, graded_at: DateTime.now
      submission.update_attributes submitted_at: DateTime.now
      expect(submission).to be_resubmitted
    end

    it "returns false if the grade was graded after it was submitted" do
      submission.submitted_at = DateTime.now
      submission.save
      create :grade, status: "Graded", submission: submission,
        assignment: submission.assignment, graded_at: DateTime.now
      expect(submission).to_not be_resubmitted
    end

    it "returns false if it was not graded" do
      create :grade, status: "Graded", submission: submission,
        assignment: submission.assignment
      expect(submission).to_not be_resubmitted
    end
  end

  describe "#name" do
    it "returns the student's name" do
      student = create(:user, first_name: "Joon", last_name: "Pearl")
      submission = create(:submission, student: student)
      expect(submission.name).to eq("Joon Pearl")
    end
  end

  describe "#submitter" do
    let(:submission) { create :submission }

    context "submission uses groups" do
      it "returns the group" do
        group = double :group
        allow(submission.assignment).to receive(:has_groups?) { true }
        allow(submission).to receive(:group) { group }

        expect(submission.submitter).to eq group
      end
    end

    context "submissions doesn't use groups" do
      it "returns the student" do
        allow(submission.assignment).to receive(:has_groups?) { false }

        expect(submission.submitter).to eq submission.student
      end
    end
  end

  describe "#submitter_id" do
    context "submission uses groups" do
      let(:submission) { build_stubbed :group_submission, group_id: 20 }

      it "returns the group id" do
        allow(submission.assignment).to receive(:has_groups?) { true }
        expect(submission.submitter_id).to eq 20
      end
    end

    context "submissions doesn't use groups" do
      let(:submission) { build_stubbed :submission, student_id: 30 }

      it "returns the student" do
        allow(submission.assignment).to receive(:has_groups?) { false }
        expect(submission.submitter_id).to eq 30
      end
    end
  end

  describe "#check_and_set_late_status!" do
    context "when the assignment has a due_at date" do
      context "with a submission that is late" do
        it "sets the late attribute as true" do
          assignment = create(:assignment, due_at: DateTime.now - 1)
          submission = create(:submission, assignment: assignment, submitted_at: DateTime.now)
          expect(submission.check_and_set_late_status!).to eq true
          expect(submission.late?).to eq(true)
        end
      end

      context "with a submission that is not late" do
        it "sets the late attribute as false" do
          assignment = create(:assignment, due_at: DateTime.now)
          submission = create(:submission, assignment: assignment, submitted_at: DateTime.now - 1)
          expect(submission.check_and_set_late_status!).to eq true
          expect(submission.late?).to eq(false)
        end
      end
    end

    context "when the assignment does not have a due_at date" do
      it "returns false" do
        expect(submission.check_and_set_late_status!).to eq false
      end
    end
  end

  describe "#has_multiple_components?" do
    it "returns true for any submission that has more than one file attachment" do
      assignment = create(:assignment, due_at: Date.today + 1)
      submission = create(:submission, assignment: assignment)
      file_1 = create(:submission_file, submission: submission)
      file_2 = create(:submission_file, submission: submission)

      expect(submission.has_multiple_components?).to eq(true)
    end

    it "returns true for any submission that has a link and a text comment" do
      assignment = create(:assignment, due_at: Date.today + 1)
      submission = create(:submission, assignment: assignment, text_comment: "Having a Boo Radley moment, are we?", link: "http://www.gradecraft.com")

      expect(submission.has_multiple_components?).to eq(true)
    end

    it "returns true for any submission that has one attachment and a text comment" do
      assignment = create(:assignment, due_at: Date.today + 1)
      submission = create(:submission, assignment: assignment, text_comment: "Soap on a rope, slightly used")
      file_1 = create(:submission_file, submission: submission)

      expect(submission.has_multiple_components?).to eq(true)
    end

    it "returns false for any submission that has just a text comment" do
      assignment = create(:assignment, due_at: Date.today + 1)
      submission = create(:submission, assignment: assignment, text_comment: "Raisins are really just humiliated grapes.")

      expect(submission.has_multiple_components?).to eq(false)
    end

    it "returns false for any submission that has just a link" do
      assignment = create(:assignment, due_at: Date.today + 1)
      submission = create(:submission, assignment: assignment, link: "http://www.gradecraft.com", text_comment: nil)

      expect(submission.has_multiple_components?).to eq(false)
    end
  end

  describe "#check_unlockables" do
  end

  describe "#base_filename" do
    before do
      allow(submission).to receive_message_chain(:student, :name) { "Dan Ho" }
      allow(submission).to receive_message_chain(:assignment, :name) { "Great" }
    end

    it "titleizes the student's full name and assignment name" do
      expect(Formatter::Filename).to receive(:titleize).with "Dan Ho"
      expect(Formatter::Filename).to receive(:titleize).with "Great"
      submission.base_filename
    end

    it "returns the combination of the titleized student and assignment names" do
      expect(submission.base_filename).to eq "Dan Ho - Great"
    end
  end

  describe "#unsubmitted?" do
    it "returns true if the submitted at date is nil" do
      submission.submitted_at = nil
      expect(submission.unsubmitted?).to eq true
    end

    it "returns false if the submitted at date is not nil" do
      submission.submitted_at = DateTime.now
      expect(submission.unsubmitted?).to eq false
    end
  end

  describe "#belongs_to?" do
    let(:student) { create(:user) }

    context "when the assignment is individual" do
      it "returns true if the student_id equals the user id" do
        submission.student_id = student.id
        expect(submission.belongs_to?(student)).to eq true
      end
    end

    context "when the assignment is for groups" do
      before(:each) { allow(submission).to receive(:assignment).and_return build_stubbed(:group_assignment) }

      let!(:group_membership) { create(:group_membership, student: student) }

      it "returns true if the student's group memberships include the group id" do
        submission.group_id = group_membership.group_id
        expect(submission.belongs_to?(student)).to eq true
      end
    end
  end
end
