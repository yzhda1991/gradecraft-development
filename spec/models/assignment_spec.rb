require "active_record_spec_helper"

describe Assignment do
  subject { build(:assignment) }

  context "validations" do
    it "is valid with a name and assignment type" do
      expect(subject).to be_valid
    end

    it "is invalid without a name" do
      subject.name = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to include "can't be blank"
    end

    it "is invalid without an assignment type" do
      subject.assignment_type_id = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:assignment_type_id]).to include "can't be blank"
    end
  end

  describe "gradebook for assignment" do
    it "returns sample csv data, including ungraded students" do
      course = create(:course)
      course.assignments << subject
      student = create(:user)
      student.courses << course
      submission = create(:submission, student: student, assignment: subject)
      expect(subject.gradebook_for_assignment).to eq("First Name,Last Name,Uniqname,Score,Raw Score,Statement,Feedback,Last Updated\n#{student.first_name},#{student.last_name},#{student.username},\"\",\"\",\"#{submission.text_comment}\",\"\"\n")
    end

    it "also returns grade fields with instructor modified grade" do
      course = create(:course)
      course.assignments << subject
      student = create(:user)
      student.courses << course
      grade = create(:grade, raw_score: 100, assignment: subject, student: student, feedback: "good jorb!", instructor_modified: true)
      submission = create(:submission, grade: grade, student: student, assignment: subject)
      expect(subject.gradebook_for_assignment(converters: :date_time)).to eq("First Name,Last Name,Uniqname,Score,Raw Score,Statement,Feedback,Last Updated\n#{student.first_name},#{student.last_name},#{student.username},100,100,\"#{submission.text_comment}\",good jorb!,\"#{grade.updated_at}\"\n")
    end
  end

  describe "pass-fail assignments" do
    it "sets point total to zero on save" do
      subject.point_total = 3000
      subject.pass_fail = true
      subject.save
      expect(subject.point_total).to eq(0)
    end
  end

  describe "#copy" do
    let(:assignment) { build :assignment }
    subject { assignment.copy }

    it "prepends the name with 'Copy of'" do
      assignment.name = "Table of elements"
      expect(subject.name).to eq "Copy of Table of elements"
    end

    it "makes a shallow copy of the fields" do
      assignment.description = "This is a great assignment"
      expect(subject.description).to eq "This is a great assignment"
    end

    it "saves the copy if the assignment is saved" do
      assignment.save
      expect(subject).to_not be_new_record
    end

    it "copies the assignment score levels" do
      assignment.save
      assignment.assignment_score_levels.create
      expect(subject.assignment_score_levels.size).to eq 1
      expect(subject.assignment_score_levels.map(&:assignment_id)).to eq [subject.id]
    end

    it "copies the rubric" do
      assignment.save
      assignment.build_rubric
      expect(subject.rubric.assignment_id).to eq subject.id
      expect(subject.rubric).to_not be_new_record
    end
  end
end
