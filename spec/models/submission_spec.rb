require "active_record_spec_helper"
require "toolkits/historical_toolkit"
require "toolkits/sanitization_toolkit"

describe Submission do
  subject { build(:submission) }

  describe "validations" do
    it { is_expected.to be_valid }

    it "requires a valid url" do
      subject.link = "not a url"
      expect(subject).to_not be_valid
      expect(subject.errors[:link]).to include "is invalid"
    end

    it "requires something to have been submitted" do
      subject.link = nil
      subject.text_comment = nil
      subject.submission_files.clear
      expect(subject).to_not be_valid
      expect(subject.errors[:base]).to include "Submission cannot be empty"
    end
  end

  it_behaves_like "a historical model", :submission, link: "http://example.org"
  it_behaves_like "a model that needs sanitization", :text_comment

  describe "versioning", versioning: true do
    before { subject.save }

    it "creates a version when the link is updated" do
      previous_link = subject.link
      subject.update_attributes link: "http://example.com"
      expect(subject).to have_a_version_with link: previous_link
    end

    it "creates a version when the attachment is updated" do
      subject.submission_files.create(filename: "test",
                                      filepath: "polsci101/submissionfile/",
                                      file: fixture_file("test_image.jpg", "img/jpg"))
      expect(subject.submission_files[0].versions.count).to eq 1
    end

    it "creates a version when the comment is updated" do
      previous_comment = subject.text_comment
      subject.update_attributes text_comment: "This was updated"
      expect(subject).to have_a_version_with text_comment: previous_comment
    end
  end

  it "can be saved with only a text comment" do
    subject.text_comment = "I volunteer! I volunteer! I volunteer as tribute!"
    subject.save!
    expect(subject.errors.size).to eq(0)
  end

  it "can be saved with only a link" do
    subject.link = "http://www.amazon.com/dp/0439023521"
    subject.save!
    expect expect(subject.errors.size).to eq(0)
  end

  it "can be saved with only an attached file" do
    subject.submission_files.new(filename: "test", filepath: "polsci101/submissionfile/", file: fixture_file("test_image.jpg", "img/jpg"))
    subject.save!
    expect expect(subject.errors.size).to eq(0)
  end

  it "can have an an attached file, comment, and link" do
    subject.text_comment = "I volunteer! I volunteer! I volunteer as tribute!"
    subject.link = "http://www.amazon.com/dp/0439023521"
    subject.submission_files.new(filename: "test", filepath: "polsci101/submissionfile/", file: fixture_file("test_image.jpg", "img/jpg"))
    subject.save!
    expect expect(subject.errors.size).to eq(0)
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
      student = create(:user)
      student_submission = create(:submission, student: student)
      another_submission = create(:submission)
      results = Submission.for_student(student)
      expect(results).to eq [student_submission]
    end
  end

  describe "#submission_files_attributes=" do
    it "supports multiple file uploads" do
      file_attribute_1 = fixture_file "test_file.txt", "txt"
      file_attribute_2 = fixture_file "test_image.jpg", "image/jpg"
      subject.submission_files_attributes = { "0" => { "file" => [file_attribute_1, file_attribute_2] }}
      expect(subject.submission_files.length).to eq 2
      expect(subject.submission_files[0].filename).to eq "test_file.txt"
      expect(subject.submission_files[1].filename).to eq "test_image.jpg"
    end
  end

  describe "#updatable_by?(user)" do
    it "returns true for the student whose submission it is" do
      student = create(:user)
      assignment = create(:assignment, grade_scope: "Individual")
      submission = create(:submission, assignment: assignment, student: student)
      expect(submission.updatable_by?(student)).to eq(true)
    end

    it "returns false for any student whose submission it is not" do
      student = create(:user)
      assignment = create(:assignment, grade_scope: "Individual")
      submission = create(:submission, assignment: assignment)
      expect(submission.updatable_by?(student)).to eq(false)
    end

    it "returns true for any student in a group whose submission it is" do
      student = create(:user)
      assignment = create(:assignment, grade_scope: "Group")
      group = create(:group)
      group.students << student
      assignment.groups << group

      submission = create(:submission, assignment: assignment, group: group)
      expect(submission.updatable_by?(student)).to eq(true)
    end

    it "returns false for any student in other groups whose submission it is not" do
      student = create(:user)
      assignment = create(:assignment, grade_scope: "Group")
      group = create(:group)
      group.students << student
      assignment.groups << group

      submission = create(:submission, assignment: assignment)
      expect(submission.updatable_by?(student)).to eq(false)
    end

    it "returns true for any staff user" do
      professor = create(:user)
      course = create(:course)
      create :professor_course_membership, user: professor, course: course
      submission = create(:submission, course: course)
      expect(submission).to be_updatable_by professor
    end
  end

  describe "#destroyable_by?(user)" do
    it "returns true for the student whose submission it is" do
      student = create(:user)
      assignment = create(:assignment, grade_scope: "Individual")
      submission = create(:submission, assignment: assignment, student: student)
      expect(submission.destroyable_by?(student)).to eq(true)
    end

    it "returns false for any student whose submission it is not" do
      student = create(:user)
      assignment = create(:assignment, grade_scope: "Individual")
      submission = create(:submission, assignment: assignment)
      expect(submission.destroyable_by?(student)).to eq(false)
    end

    it "returns true for any student in a group whose submission it is" do
      student = create(:user)
      assignment = create(:assignment, grade_scope: "Group")
      group = create(:group)
      group.students << student
      assignment.groups << group

      submission = create(:submission, assignment: assignment, group: group)
      expect(submission.destroyable_by?(student)).to eq(true)
    end

    it "returns false for any student in other groups whose submission it is not" do
      student = create(:user)
      assignment = create(:assignment, grade_scope: "Group")
      group = create(:group)
      group.students << student
      assignment.groups << group

      submission = create(:submission, assignment: assignment)
      expect(submission.destroyable_by?(student)).to eq(false)
    end

    it "returns true for any staff user" do
      professor = create(:user)
      course = create(:course)
      create :professor_course_membership, user: professor, course: course
      submission = create(:submission, course: course)
      expect(submission).to be_destroyable_by professor
    end
  end

  describe "#viewable_by?(user)" do
    it "returns true for the student whose submission it is" do
      student = create(:user)
      assignment = create(:assignment, grade_scope: "Individual")
      submission = create(:submission, assignment: assignment, student: student)
      expect(submission.viewable_by?(student)).to eq(true)
    end

    it "returns false for any student whose submission it is not" do
      student = create(:user)
      assignment = create(:assignment, grade_scope: "Individual")
      submission = create(:submission, assignment: assignment)
      expect(submission.viewable_by?(student)).to eq(false)
    end

    it "returns true for any student in a group whose submission it is" do
      student = create(:user)
      assignment = create(:assignment, grade_scope: "Group")
      group = create(:group)
      group.students << student
      assignment.groups << group

      submission = create(:submission, assignment: assignment, group: group)
      expect(submission.viewable_by?(student)).to eq(true)
    end

    it "returns false for any student in other groups whose submission it is not" do
      student = create(:user)
      assignment = create(:assignment, grade_scope: "Group")
      group = create(:group)
      group.students << student
      assignment.groups << group

      submission = create(:submission, assignment: assignment)
      expect(submission.viewable_by?(student)).to eq(false)
    end

    it "returns true for any staff user" do
      professor = create(:user)
      course = create(:course)
      create :professor_course_membership, user: professor, course: course
      submission = create(:submission, course: course)
      expect(submission).to be_viewable_by professor
    end
  end

  describe "#graded_at" do
    it "returns when the grade was graded if it was graded" do
      subject.save
      graded_at = DateTime.now
      grade = create(:grade, submission: subject, status: "Graded", graded_at: graded_at)
      expect(subject.graded_at).to eq graded_at
    end

    it "returns nil if there is no grade" do
      subject.save
      expect(subject.graded_at).to be_nil
    end

    it "returns nil if the grade is not released" do
      subject.save
      grade = create(:grade, submission: subject)
      expect(subject.graded_at).to be_nil
    end
  end

  describe "#graded?" do
    it "returns false for a submission that has no grade" do
      subject.save
      expect(subject).to_not be_graded
    end

    it "returns false for a submission that has grade that is not student visible" do
      subject.save
      grade = create(:grade, submission: subject)
      expect(subject).to_not be_graded
    end

    it "returns true for a submission that has grade that is student visible" do
      subject.save
      grade = create(:grade, submission: subject, status: "Graded")
      expect(subject).to be_graded
    end
  end

  describe "#ungraded?" do
    it "returns true for a submission that has no grade" do
      subject.save
      expect(subject).to be_ungraded
    end

    it "returns true for a submission that has grade that is not student visible" do
      subject.save
      grade = create(:grade, submission: subject)
      expect(subject).to be_ungraded
    end

    it "returns false for a submission that has grade that is student visible" do
      subject.save
      grade = create(:grade, submission: subject, status: "Graded")
      expect(subject).to_not be_ungraded
    end
  end

  describe ".resubmitted" do
    it "returns the submissions that have been submitted after they were graded" do
      grade = create(:grade, submission: subject, status: "Graded", graded_at: 1.day.ago)
      subject.submitted_at = DateTime.now
      subject.save
      expect(Submission.resubmitted).to eq [subject]
    end

    it "does not return non-graded or released grades" do
      grade = create(:grade, submission: subject, graded_at: 1.day.ago)
      subject.submitted_at = DateTime.now
      subject.save
      expect(Submission.resubmitted).to be_empty
    end

    it "does not return resubmissions that have been graded" do
      grade = create(:grade, submission: subject, status: "Graded", graded_at: 1.day.ago)
      subject.submitted_at = 2.days.ago
      subject.save
      expect(Submission.resubmitted).to be_empty
    end
  end

  describe ".order_by_submitted" do
    it "returns the submissions in the order they were submitted" do
      Submission.delete_all
      submitted_yesterday = create(:submission, submitted_at: 1.day.ago)
      never_submitted = create(:submission)
      just_submitted = create(:submission, submitted_at: DateTime.now)

      expect(Submission.order_by_submitted).to eq [submitted_yesterday, just_submitted, never_submitted]
    end
  end

  describe "#will_be_resubmission?", versioning: true do
    before { subject.save }

    it "returns false if there is no grade" do
      expect(subject).to_not be_will_be_resubmission
    end

    it "returns true if there is a grade" do
      create :grade, status: "Graded", submission: subject, assignment: subject.assignment

      expect(subject).to be_will_be_resubmission
    end
  end

  describe "#resubmitted?", versioning: true do
    it "returns false if there are no resubmissions" do
      expect(subject).to_not be_resubmitted
    end

    it "returns true if there are resubmissions" do
      subject.save
      grade = create :grade, status: "Graded", submission: subject,
        assignment: subject.assignment
      subject.update_attributes link: "http://example.com"
      grade.update_attributes raw_score: 1234

      expect(subject).to be_resubmitted
    end
  end

  describe "#resubmissions", versioning: true do
    it "caches the resubmissions" do
      expect(Resubmission).to receive(:find_for_submission).with(subject).once.and_call_original
      2.times { subject.resubmissions }
    end

    context "with no resubmissions" do
      it "returns an empty array" do
        expect(subject.resubmissions).to be_empty
      end
    end

    context "with a single resubmission" do
      let(:grade) do
        create :grade, status: "Graded", submission: subject, assignment: subject.assignment
      end

      before do
        subject.save
        grade.update_attributes raw_score: 1234
        subject.update_attributes link: "http://example.com"
      end

      it "returns an array of resubmissions" do
        results = subject.resubmissions

        expect(results.length).to eq 1
        expect(results.first.submission).to eq subject
      end
    end
  end

  describe "#name" do
    it "returns the student's name" do
      student = create(:user, first_name: "Joon", last_name: "Pearl")
      submission = create(:submission, student: student)
      expect(submission.name).to eq("Joon Pearl")
    end
  end

  describe "#late?" do
    it "returns true if the submission was created after the due date" do
      assignment = create(:assignment, due_at: Date.today - 1)
      submission = create(:submission, assignment: assignment)
      expect(submission.late?).to eq(true)
    end

    it "returns false if the submission was created before the due date" do
      assignment = create(:assignment, due_at: Date.today + 1)
      submission = create(:submission, assignment: assignment)
      expect(submission.late?).to eq(false)
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
    # if self.assignment.is_a_condition?
    #   unlock_conditions = UnlockCondition.where(:condition_id => self.assignment.id, :condition_type => "Assignment").each do |condition|
    #     unlockable = condition.unlockable
    #     unlockable.check_unlock_status(student)
    #   end
    # end
  end
end
