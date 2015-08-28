#grade_spec.rb

require 'spec_helper'

describe Grade do

  before do
    @grade = build(:grade)
  end

  subject { @grade }

  it { is_expected.to respond_to("admin_notes")}
  it { is_expected.to respond_to("assignment_id")}
  it { is_expected.to respond_to("assignment_type_id")}
  it { is_expected.to respond_to("attempted")}
  it { is_expected.to respond_to("complete")}
  it { is_expected.to respond_to("course_id")}
  it { is_expected.to respond_to("created_at")}
  it { is_expected.to respond_to("feedback")}
  it { is_expected.to respond_to("final_score")}
  it { is_expected.to respond_to("finals")}
  it { is_expected.to respond_to("graded_by_id")}
  it { is_expected.to respond_to("group_id")}
  it { is_expected.to respond_to("group_type")}
  it { is_expected.to respond_to("instructor_modified")}
  it { is_expected.to respond_to("pass_fail_status")}
  it { is_expected.to respond_to("point_total")}
  it { is_expected.to respond_to("predicted_score")}
  it { is_expected.to respond_to("raw_score")}
  it { is_expected.to respond_to("score")}
  it { is_expected.to respond_to("semis")}
  it { is_expected.to respond_to("shared")}
  it { is_expected.to respond_to("status")}
  it { is_expected.to respond_to("student_id")}
  it { is_expected.to respond_to("submission_id")}
  it { is_expected.to respond_to("substantial")}
  it { is_expected.to respond_to("task_id")}
  it { is_expected.to respond_to("team_id")}
  it { is_expected.to respond_to("type")}
  it { is_expected.to respond_to("updated_at")}


  it { is_expected.to be_valid }

  it "is valid with an assignment, student, assignment_type, and course" do
    expect(build(:grade)).to be_valid
  end

  it "is invalid without an assignment" do
    # delegations to assignment cause errors on save,
    # maybe there is a better way to test this?
    @grade.assignment = nil
    expect{@grade.save!}.to raise_error
  end

  it "is invalid without a student" do
    @grade.student = nil
    expect(@grade).to_not be_valid
    expect(@grade.errors[:student].count).to eq 1
  end

  it "is invalid without a course" do
    @grade.course = nil
    expect(@grade).to_not be_valid
    expect(@grade.errors[:course].count).to eq 1
  end

  it "is invalid without an assignment type" do
    @grade.assignment.assignment_type = nil
    expect(@grade).to_not be_valid
    expect(@grade.errors[:assignment_type].count).to eq 1
  end

  it "does not allow duplicate grades per student" do
    @grade.save!
    expect(build(:grade, course: @grade.course, assignment: @grade.assignment, student: @grade.student)).to_not be_valid
  end

  describe "when assignment is pass-fail" do
    before do
      @grade.assignment.update(pass_fail: true)
    end

    it "saves the grades as zero" do
      @grade.save!
      expect(@grade.raw_score).to be 0
      expect(@grade.predicted_score).to be <= 1
      expect(@grade.final_score).to be 0
      expect(@grade.point_total).to be 0
    end
  end

  describe "#feedback_read!" do
    it "marks the grade as read" do
      @grade.feedback_read!
      expect(@grade).to be_feedback_read
      elapsed = ((DateTime.now - @grade.feedback_read_at.to_datetime) * 24 * 60 * 60).to_i
      expect(elapsed).to be < 5
    end
  end

  describe "#feedback_reviewed!" do
    it "marks the grade as reviewed" do
      @grade.feedback_reviewed!
      expect(@grade).to be_feedback_reviewed
      elapsed = ((DateTime.now - @grade.feedback_reviewed_at.to_datetime) * 24 * 60 * 60).to_i
      expect(elapsed).to be < 5
    end
  end
end
