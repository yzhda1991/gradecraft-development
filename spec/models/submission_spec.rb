require "active_record_spec_helper"

describe Submission do
  subject { build(:submission) }

  describe "validations" do
    it { is_expected.to be_valid }

    it "requires a valid url" do
      subject.link = "not a url"
      expect(subject).to_not be_valid
      expect(subject.errors[:link]).to include "is invalid"
    end
  end

  describe "versioning", versioning: true do
    before { subject.save }

    it "is enabled for submissions" do
      expect(PaperTrail).to be_enabled
      expect(subject).to be_versioned
    end

    it "creates a version when the submission is created" do
      expect(subject.versions.count).to eq 1
    end

    it "creates a version when the link is updated" do
      previous_link = subject.link
      subject.update_attributes link: "http://example.com"
      expect(subject).to have_a_version_with link: previous_link
    end

    it "creates a version when the attachment is updated" do
      subject.submission_files.create(filename: "test",
                                      filepath: "polsci101/submissionfile/",
                                      file: fixture_file('test_image.jpg', 'img/jpg'))
      expect(subject.submission_files[0].versions.count).to eq 1
    end

    it "creates a version when the comment is updated" do
      previous_comment = subject.text_comment
      subject.update_attributes text_comment: "This was updated"
      expect(subject).to have_a_version_with text_comment: previous_comment
    end
  end

  describe "#history", versioning: true, focus: true do
    let(:user) { create :user }

    before do
      PaperTrail.whodunnit = user.id
      subject.save
    end

    it "returns the changesets for the created submission" do
      expect(subject.history.length).to eq 1
      expect(subject.history.first.keys).to include("created_at")
      expect(subject.history.first).to include({ "object" => "Submission" })
      expect(subject.history.first).to include({ "event" => "create" })
      expect(subject.history.first).to include({ "actor_id" => user.id.to_s })
    end

    it "returns the changesets for an updated submission" do
      subject.update_attributes link: "http://example.org"
      expect(subject.history.length).to eq 2
      expect(subject.history.last).to include({ "link" => [nil, "http://example.org"] })
      expect(subject.history.last).to include({ "object" => "Submission" })
      expect(subject.history.last).to include({ "event" => "update" })
      expect(subject.history.last).to include({ "actor_id" => user.id.to_s })
    end
  end

  it "can't be saved without any information" do
    subject.link = nil
    subject.text_comment = nil
    expect { subject.save! }.to raise_error(ActiveRecord::RecordNotSaved)
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
    subject.submission_files.new(filename: "test", filepath: "polsci101/submissionfile/", file: fixture_file('test_image.jpg', 'img/jpg'))
    subject.save!
    expect expect(subject.errors.size).to eq(0)
  end

  it "can have an an attached file, comment, and link" do
    subject.text_comment = "I volunteer! I volunteer! I volunteer as tribute!"
    subject.link = "http://www.amazon.com/dp/0439023521"
    subject.submission_files.new(filename: "test", filepath: "polsci101/submissionfile/", file: fixture_file('test_image.jpg', 'img/jpg'))
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

  describe "#ungraded?" do
    it "returns true for a submission that has no grade" do
      submission = create(:submission)
      expect(submission.ungraded?).to eq(true)
    end

    it "returns true for a submission that has grade that is not student visible" do
      submission = create(:submission)
      grade = create(:grade, submission: submission)
      expect(submission.ungraded?).to eq(true)
    end

    it "returns false for a submission that has grade that is student visible" do
      submission = create(:submission)
      grade = create(:grade, submission: submission, status: "Graded")
      expect(submission.ungraded?).to eq(false)
    end
  end

  describe "#resubmitted?" do
    #student.grade_for_assignment(assignment).present? && student.grade_for_assignment(assignment).updated_at < self.updated_at
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
