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
  end

  # Grabbing any submission that has NO instructor-defined grade (if the student has predicted the grade,
  # it'll exist, but we still don't want to catch those here)
  describe "#ungraded?" do
    #! grade || grade.status == nil
  end

  describe "#resubmitted?" do
    #student.grade_for_assignment(assignment).present? && student.grade_for_assignment(assignment).updated_at < self.updated_at
  end


  #Permissions regarding who can see a grade
  describe "#viewable_by?(user)" do
    # if assignment.is_individual?
    #   student_id == user.id
    # elsif assignment.has_groups?
    #   group_id == user.group_for_assignment(assignment).id
    # end
  end

  # Getting the name of the student who submitted the work
  describe "#name" do
    #student.name
  end

  # Checking to see if a submission was turned in late
  describe "#late?" do
    #created_at > self.assignment.due_at if self.assignment.due_at.present?
  end

  describe "#has_multiple_components?" do
    # return true if (submission_files.count > 1) || (submission_files.present? && (link.present? || text_comment.present?))
    # false
  end

  describe "#check_unlockables" do
    # if self.assignment.is_a_condition?
    #   unlock_conditions = UnlockCondition.where(:condition_id => self.assignment.id, :condition_type => "Assignment").each do |condition|
    #     if condition.unlockable_type == "Assignment"
    #       unlockable = Assignment.find(condition.unlockable_id)
    #       unlockable.check_unlock_status(student)
    #     elsif condition.unlockable_type == "Badge"
    #       unlockable = Badge.find(condition.unlockable_id)
    #       unlockable.check_unlock_status(student)
    #     end
    #   end
    # end
  end
end
