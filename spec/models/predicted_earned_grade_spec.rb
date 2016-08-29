require "active_record_spec_helper"

describe PredictedEarnedGrade do

  before do
    @predicted_earned_grade = create(:predicted_earned_grade)
  end

  subject { @predicted_earned_grade }

  it { is_expected.to respond_to("student_id")}
  it { is_expected.to respond_to("assignment_id")}
  it { is_expected.to respond_to("predicted_points")}

  it { is_expected.to be_valid }

  describe ".for_course" do
    it "returns all predicted earned grades for a specific course" do
      course = create(:course)
      course_predicted_grade = create(:predicted_earned_grade,
                                    assignment: create(:assignment, course: course))
      another_predicted_grade = create(:predicted_earned_grade)
      results = PredictedEarnedGrade.for_course(course)
      expect(results).to eq [course_predicted_grade]
    end
  end

  describe ".for_student" do
    it "returns all predicted earned grades for a specific student" do
      student = create(:user)
      student_predicted_grade = create(:predicted_earned_grade,
                                           student: student)
      another_predicted_grade = create(:predicted_earned_grade)
      results = PredictedEarnedGrade.for_student(student)
      expect(results).to eq [student_predicted_grade]
    end
  end
end
