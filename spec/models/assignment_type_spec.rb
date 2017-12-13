describe AssignmentType do
  let(:course) { build :course }
  let(:assignment) { build :assignment, course: course }
  let(:student) { create(:course_membership, course: course, role: :student).user }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:grade) { create :grade, assignment: assignment }
  let(:assignment_type) { create :assignment_type, course: course }

  describe "validations" do
    subject { build(:assignment_type) }

    it "is valid with a name" do
      expect(subject).to be_valid
    end

    it "is invalid without a name" do
      subject.name = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to include "can't be blank"
    end

    it "is only valid with positive max points" do
      subject.max_points = -1000
      expect(subject).to be_invalid
    end

    it "is only valid with top_grades_counted" do
      subject.top_grades_counted = -10
      expect(subject).to be_invalid
    end
  end

  describe "#copy" do
    subject { assignment_type.copy }

    it "makes a duplicated copy of itself" do
      expect(subject).to_not eq assignment_type
    end

    it "saves the copy if the course is saved" do
      assignment_type.save
      expect(subject).to_not be_new_record
    end

    it "copies the assignments" do
      assignment_type.save
      create :assignment, assignment_type: assignment_type
      expect(subject.assignments.size).to eq 1
      expect(subject.assignments.map(&:assignment_type_id)).to eq [subject.id]
    end
  end

  describe "#weight_for_student(student)" do
    it "returns 1 unless the assignment is student weightable" do
      expect(assignment_type.weight_for_student(student))
    end

    it "returns a weight if a student has assigned it" do
      assignment_type.student_weightable = true
      assignment = create(:assignment, assignment_type: assignment_type, course: course)
      create(:assignment_type_weight, student: student, course: course, assignment_type: assignment_type, weight: 3)

      expect(assignment_type.weight_for_student(student)).to eq(3)
    end
  end

  describe "#is_capped?" do
    it "returns false if the assignment type has no max value and is set to false" do
      expect(assignment_type.is_capped?).to eq(false)
    end

    it "returns true if the assignment type has a max value" do
      assignment_type.has_max_points = true
      assignment_type.max_points = 10000
      expect(assignment_type.is_capped?).to eq(true)
    end
  end

  describe "#count_only_top_grades?" do
    it "returns false if the assignment type has no max value" do
      expect(assignment_type.count_only_top_grades?).to eq(false)
    end

    it "returns true if the assignment type has a max value" do
      assignment_type.top_grades_counted = 10
      expect(assignment_type.count_only_top_grades?).to eq(true)
    end
  end

  describe "#total_points" do
    it "returns true if the assignment type has max points" do
      assignment_type.has_max_points = true
      assignment_type.max_points = 10000
      expect(assignment_type.total_points).to eq(10000)
    end

    it "returns the sum of the assignments in the assignment type if it does not have max points" do
      create(:assignment, assignment_type: assignment_type, full_points: 100)
      expect(assignment_type.total_points).to eq(100)
    end
  end

  describe "#total_points_for_student(student)" do
    it "returns the max points if they are present" do
      assignment_type.has_max_points = true
      assignment_type.max_points = 10000
      expect(assignment_type.total_points_for_student(student)).to eq(10000)
    end

    it "returns the weighted total for the student" do
      assignment_type.student_weightable = true
      assignment = create(:assignment, assignment_type: assignment_type, course: course, full_points: 100)
      create(:assignment_type_weight, student: student, course: course, assignment_type: assignment_type, weight: 3)

      expect(assignment_type.total_points_for_student(student)).to eq(300)
    end

    it "returns the total number of points if it's not weightable and there's no cap" do
      assignment = create(:assignment, assignment_type: assignment_type, course: course, full_points: 100)
      expect(assignment_type.total_points_for_student(student)).to eq(100)
    end
  end

  describe "#summed_assignment_points" do
    it "returns the sum of the assignments in the assignment type if it does not have max points" do
      create(:assignment, assignment_type: assignment_type, full_points: 100)
      create(:assignment, assignment_type: assignment_type, full_points: 100)
      create(:assignment, assignment_type: assignment_type, full_points: 100)
      expect(assignment_type.summed_assignment_points).to eq(300)
    end
  end

  describe "#weighted_total_for_student(student)" do
    it "returns the weighted total if the student has assigned weight to it" do
      assignment_type.student_weightable = true
      assignment = create(:assignment, assignment_type: assignment_type, course: course, full_points: 100)
      create(:assignment_type_weight, student: student, course: course, assignment_type: assignment_type, weight: 3)

      expect(assignment_type.weighted_total_for_student(student)).to eq(300)
    end

    it "returns zero for total if the student has *not* assigned weight to it" do
      assignment_type.student_weightable = true
      assignment = create(:assignment, assignment_type: assignment_type, course: course, full_points: 100)

      expect(assignment_type.weighted_total_for_student(student)).to eq(0)
    end
  end

  describe "#visible_score_for_student(student)" do
    it "returns the student score if there is are no caps" do
      assignment = create(:assignment, course: course, assignment_type: assignment_type)
      grade = create(:student_visible_grade, student: student, raw_points: 1000, assignment: assignment)
      expect(assignment_type.visible_score_for_student(student)).to eq(1000)
    end

    it "returns the max points if present" do
      assignment_type.has_max_points = true
      assignment_type.max_points = 100
      assignment = create(:assignment, course: course, assignment_type: assignment_type, full_points: 99)
      grade = create(:student_visible_grade, student: student, raw_points: 1000, assignment: assignment)
      expect(assignment_type.visible_score_for_student(student)).to eq(100)
    end

    it "returns the top X score if present" do
      assignment_type.top_grades_counted = 2
      assignment = create(:assignment, course: course, assignment_type: assignment_type)
      assignment_2 = create(:assignment, course: course, assignment_type: assignment_type)
      assignment_3 = create(:assignment, course: course, assignment_type: assignment_type)
      grade = create(:student_visible_grade, student: student, raw_points: 100, assignment: assignment)
      grade_2 = create(:student_visible_grade, student: student, raw_points: 75, assignment: assignment_2)
      grade_3 = create(:student_visible_grade, student: student, raw_points: 25, assignment: assignment_3)
      expect(assignment_type.visible_score_for_student(student)).to eq(175)
    end
  end

  describe "#score_for_student(student)" do
    it "returns the total score a student has earned for an assignment type" do
      assignment = create(:assignment, course: course, assignment_type: assignment_type)
      assignment_2 = create(:assignment, course: course, assignment_type: assignment_type)
      grade = create(:student_visible_grade, student: student, raw_points: 100, assignment: assignment)
      grade = create(:student_visible_grade, student: student, raw_points: 100, assignment: assignment_2)
      expect(assignment_type.score_for_student(student)).to eq(200)
    end

    it "returns the total score a student has earned for an assignment type and has a reduced final score" do
      assignment = create(:assignment, course: course, assignment_type: assignment_type)
      grade = create(:student_visible_grade, student: student, raw_points: 100, adjustment_points: -25, assignment: assignment)
      expect(assignment_type.score_for_student(student)).to eq(75)
    end

    it "does return a weighted score if present"   do
      assignment_type.student_weightable = true
      assignment = create(:assignment, course: course, assignment_type: assignment_type)
      create(:assignment_type_weight, student: student, course: course, assignment_type: assignment_type, weight: 3)
      grade = create(:student_visible_grade, student: student, raw_points: 100, assignment: assignment)
      expect(assignment_type.score_for_student(student)).to eq(300)
    end
  end

  describe "#grades_for(student)" do
    it "returns the student visible grades for the assignment type" do
      assignment = create(:assignment, course: course, assignment_type: assignment_type)
      assignment_2 = create(:assignment, course: course, assignment_type: assignment_type)
      grade = create(:student_visible_grade, student: student, raw_points: 100, assignment: assignment)
      grade_2 = create(:grade, student: student, raw_points: 100, assignment: assignment_2)
      expect(assignment_type.grades_for(student)).to eq([grade])
    end

    it "returns grades with a score" do
      assignment = create(:assignment, course: course, assignment_type: assignment_type)
      assignment_2 = create(:assignment, course: course, assignment_type: assignment_type)
      grade = create(:student_visible_grade, student: student, raw_points: nil, assignment: assignment)
      grade_2 = create(:student_visible_grade, student: student, raw_points: 100, assignment: assignment_2)
      expect(assignment_type.grades_for(student)).to eq([grade_2])
    end

    it "returns grades that are not excluded" do
      assignment = create(:assignment, course: course, assignment_type: assignment_type)
      assignment_2 = create(:assignment, course: course, assignment_type: assignment_type)
      grade = create(:student_visible_grade, student: student, raw_points: 100, excluded_from_course_score: false, assignment: assignment)
      grade_2 = create(:student_visible_grade, student: student, raw_points: 100, excluded_from_course_score: true, assignment: assignment_2)
      expect(assignment_type.grades_for(student)).to eq([grade])
    end

    it "only includes the grades for this assignment type" do
      assignment_type_2 = create(:assignment_type, course: course)
      assignment = create(:assignment, course: course, assignment_type: assignment_type)
      assignment_2 = create(:assignment, course: course, assignment_type: assignment_type_2)
      grade = create(:student_visible_grade, student: student, raw_points: 100, assignment: assignment)
      grade_2 = create(:student_visible_grade, student: student, raw_points: 100, assignment: assignment_2)
      expect(assignment_type.grades_for(student)).to eq([grade])
    end
  end

  describe "#raw_points_for_student(student)" do
    it "returns the raw score if present" do
      assignment_type.student_weightable = true
      assignment = create(:assignment, course: course, assignment_type: assignment_type)
      create(:assignment_type_weight, student: student, course: course, assignment_type: assignment_type, weight: 3)
      grade = create(:student_visible_grade, student: student, raw_points: 100, assignment: assignment)
      expect(assignment_type.raw_points_for_student(student)).to eq(100)
    end
  end

  describe "#final_points_for_student(student)" do
    it "returns the final score if present" do
      assignment_type.student_weightable = true
      assignment = create(:assignment, course: course, assignment_type: assignment_type)
      create(:assignment_type_weight, student: student, course: course, assignment_type: assignment_type, weight: 3)
      grade = create(:student_visible_grade, student: student, raw_points: 100, adjustment_points: -42, assignment: assignment)
      expect(assignment_type.final_points_for_student(student)).to eq(58)
    end

    it "accounts for presence of top_grades_counted" do
      assignment_type.top_grades_counted = 1
      assignment = create(:assignment, course: course, assignment_type: assignment_type)
      grade = create(:student_visible_grade, student: student, raw_points: 200, assignment: assignment)
      assignment_2 = create(:assignment, course: course, assignment_type: assignment_type)
      grade_2 = create(:student_visible_grade, student: student, raw_points: 100, assignment: assignment_2)
      expect(assignment_type.final_points_for_student(student)).to eq(200)
    end
  end

  describe "#summed_highest_scores_for(student)" do
    it "returns the highest X number of grades" do
      assignment_type.top_grades_counted = 2
      assignment = create(:assignment, course: course, assignment_type: assignment_type)
      assignment_2 = create(:assignment, course: course, assignment_type: assignment_type)
      assignment_3 = create(:assignment, course: course, assignment_type: assignment_type)
      grade = create(:student_visible_grade, student: student, raw_points: 100, assignment: assignment)
      grade_2 = create(:student_visible_grade, student: student, raw_points: 75, assignment: assignment_2)
      grade_3 = create(:student_visible_grade, student: student, raw_points: 25, assignment: assignment_3)
      expect(assignment_type.summed_highest_scores_for(student)).to eq(175)
    end
  end

  describe "#max_points_for_student(student)" do
    it "returns the max point value for the type if present and the student has earned MORE than that cap" do
      assignment_type.has_max_points = true
      assignment_type.max_points = 100
      assignment = create(:assignment, course: course, assignment_type: assignment_type, full_points: 99)
      grade = create(:student_visible_grade, student: student, raw_points: 200, assignment: assignment)
      expect(assignment_type.max_points_for_student(student)).to eq(100)
    end

    it "returns the student score if the max point total is present but they have earned less than that value" do
      assignment_type.has_max_points = true
      assignment_type.max_points = 500
      assignment = create(:assignment, course: course, assignment_type: assignment_type, full_points: 99)
      grade = create(:student_visible_grade, student: student, raw_points: 200, assignment: assignment)
      expect(assignment_type.max_points_for_student(student)).to eq(200)
    end
  end
end
