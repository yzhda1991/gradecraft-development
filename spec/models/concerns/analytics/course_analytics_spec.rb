describe Analytics::CourseAnalytics do
  let(:course) { create :course }
  let!(:cm_1) { create :course_membership, :student, course: course, score: 1000 }
  let!(:cm_2) { create :course_membership, :student, course: course, score: 3000 }
  let!(:cm_3) { create :course_membership, :student, course: course, score: 0, auditing: true }

  describe "#student_count" do
    it "counts the number of students in a course" do
      expect(course.student_count).to eq(3)
    end
  end

  describe "#graded_student_count" do
    it "counts the number of student who are being graded in the course" do
      expect(course.graded_student_count).to eq(2)
    end
  end

  describe "#groups_to_review_count" do
    it "returns the count of all pending groups for course" do
      create(:group, course: course, approved: "Pending" )
      create(:group, course: course, approved: "Approved" )
      create(:group, course: course, approved: "Rejected" )
      expect(course.groups_to_review_count).to eq(1)
    end
  end

  describe "#scores" do
    it "returns and array of scores for non-auditing students" do
      expect(course.scores).to eq [1000,3000]
    end
  end

  describe "#average_score" do
    it "returns the average score for course" do
      expect(course.average_score).to eq 2000
    end
  end

  describe "#high_score" do
    it "returns the maximum raw score for a graded grade" do
      expect(course.high_score).to eq 3000
    end
  end

  describe "#low_score" do
    it "returns the minimum raw score for a graded grade" do
      expect(course.low_score).to eq 1000
    end
  end

  describe "#submitted_assignment_types_this_week" do
    it "returns only the submitted non-draft submissions in the past week" do
      assignment = create :assignment, course: course
      submission = create :submission, course: course, assignment: assignment
      create :draft_submission, course: course
      expect(course.submitted_assignment_types_this_week.count).to eq 1
      expect(course.submitted_assignment_types_this_week).to eq [assignment.assignment_type]
    end
  end
end
