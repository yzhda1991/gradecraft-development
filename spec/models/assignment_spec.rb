# spec/models/assignment_spec.rb
require 'spec_helper'

describe Assignment do

  before do
    @assignment = build(:assignment)
  end

  subject { @assignment }

  it { is_expected.to respond_to("accepts_attachments")}
  it { is_expected.to respond_to("accepts_links")}
  it { is_expected.to respond_to("accepts_resubmissions_until")}
  it { is_expected.to respond_to("accepts_submissions")}
  it { is_expected.to respond_to("accepts_submissions_until")}
  it { is_expected.to respond_to("accepts_text")}
  it { is_expected.to respond_to("assignment_type_id")}
  it { is_expected.to respond_to("can_earn_multiple_times")}
  it { is_expected.to respond_to("category_id")}
  it { is_expected.to respond_to("close_time")} #TODO delete and confirm, now "due_at"
  it { is_expected.to respond_to("course_id")}
  it { is_expected.to respond_to("created_at")}
  it { is_expected.to respond_to("description")}
  it { is_expected.to respond_to("due_at")}
  it { is_expected.to respond_to("grade_scheme_id")}
  it { is_expected.to respond_to("grade_scope")}
  it { is_expected.to respond_to("grading_due_at")}
  it { is_expected.to respond_to("icon")}
  it { is_expected.to respond_to("include_in_predictor")}
  it { is_expected.to respond_to("include_in_timeline")}
  it { is_expected.to respond_to("include_in_to_do")}
  it { is_expected.to respond_to("level")}
  it { is_expected.to respond_to("mass_grade_type")}
  it { is_expected.to respond_to("max_submissions")}
  it { is_expected.to respond_to("media")}
  it { is_expected.to respond_to("media_caption")}
  it { is_expected.to respond_to("media_credit")}
  it { is_expected.to respond_to("name")}
  it { is_expected.to respond_to("notify_released")}
  it { is_expected.to respond_to("open_at")}
  it { is_expected.to respond_to("open_time")} #TODO delete and confirm, now "open_at"
  it { is_expected.to respond_to("pass_fail")}
  it { is_expected.to respond_to("point_total")}
  it { is_expected.to respond_to("points_predictor_display")}
  it { is_expected.to respond_to("position")}
  it { is_expected.to respond_to("present")}
  it { is_expected.to respond_to("release_necessary")}
  it { is_expected.to respond_to("required")}
  it { is_expected.to respond_to("resubmissions_allowed")}
  it { is_expected.to respond_to("role_necessary_for_release")}
  it { is_expected.to respond_to("student_logged")}
  it { is_expected.to respond_to("thumbnail")}
  it { is_expected.to respond_to("updated_at")}
  it { is_expected.to respond_to("use_rubric")}
  it { is_expected.to respond_to("visible")}

  it { is_expected.to be_valid }

  context "validations" do
    it "is valid with a name and assignment type" do
      expect(build(:assignment)).to be_valid
    end

    it "is invalid without a name" do
      assignment = build(:assignment, name: nil)
      expect(assignment).to_not be_valid
      expect(assignment.errors[:name].count).to eq 1
    end

    it "is invalid without an assignment type" do
      assignment = build(:assignment, assignment_type: nil)
      expect(assignment).to_not be_valid
      expect(assignment.errors[:assignment_type_id].count).to eq 1
    end
  end

  describe "gradebook for assignment" do
    it "returns sample csv data, including ungraded students" do
      course = create(:course)
      course.assignments << @assignment
      student = create(:user)
      student.courses << course
      submission = create(:submission, student: student, assignment: @assignment)
      expect(@assignment.gradebook_for_assignment).to eq("First Name,Last Name,Uniqname,Score,Raw Score,Statement,Feedback,Last Updated\n#{student.first_name},#{student.last_name},#{student.username},\"\",\"\",\"#{submission.text_comment}\",\"\"\n")
    end

    it "also returns grade fields with instructor modified grade" do
      course = create(:course)
      course.assignments << @assignment
      student = create(:user)
      student.courses << course
      grade = create(:grade, raw_score: 100, assignment: @assignment, student: student, feedback: "good jorb!", instructor_modified: true)
      submission = create(:submission, grade: grade, student: student, assignment: @assignment)
      expect(@assignment.gradebook_for_assignment).to eq("First Name,Last Name,Uniqname,Score,Raw Score,Statement,Feedback,Last Updated\n#{student.first_name},#{student.last_name},#{student.username},100,100,\"#{submission.text_comment}\",good jorb!,\"#{grade.updated_at}\"\n")
    end
  end

  describe "pass-fail assignments" do
    it "sets point total to zero on save" do
      @assignment.update(point_total: 3000)
      @assignment.pass_fail = true
      @assignment.save
      expect(@assignment.point_total).to eq(0)
    end
  end

  describe "grade import" do
    it "returns sample csv data, including ungraded students" do
      course = create(:course)
      course.assignments << @assignment
      student = create(:user)
      student.courses << course
      expect(@assignment.grade_import(course.students)).to eq("First Name,Last Name,Email,Score,Feedback\n#{student.first_name},#{student.last_name},#{student.email},\"\",\"\"\n")
    end

    it "also returns grade fields with instructor modified grade" do
      course = create(:course)
      course.assignments << @assignment
      student = create(:user)
      student.courses << course
      grade = create(:grade, assignment: @assignment, student: student, feedback: "good jorb!", instructor_modified: true)
      submission = create(:submission, grade: grade, student: student, assignment: @assignment)
      expect(@assignment.grade_import(course.students)).to eq("First Name,Last Name,Email,Score,Feedback\n#{student.first_name},#{student.last_name},#{student.email},#{grade.score},#{grade.feedback}\n")
    end
  end
end
