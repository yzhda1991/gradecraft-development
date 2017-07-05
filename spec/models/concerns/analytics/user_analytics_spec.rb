describe Analytics::UserAnalytics do
  let(:course) { create(:course) }
  let(:student) { create(:course_membership, :student, course: course, score: 100000).user }
  let(:assignment) { create(:assignment, course: course) }
  let(:grade) { create(:grade, assignment: assignment, student:student) }
  let(:badge) { create(:badge, course: course, can_earn_multiple_times: true) }
  let(:single_badge) { create(:badge, course: course, can_earn_multiple_times: false) }

  describe "#score_for_course(course)" do
    it "returns the student's score for the course" do
      expect(student.score_for_course(course)).to eq(100000)
    end

    # There is a non-null constraint on course_membership.score, so I'm not
    # sure what this is really testing.
    it "returns null if the student has no course memebership" do
      student.course_memberships.where(course_id: course).destroy_all
      expect(student.score_for_course(course)).to be_nil
    end
  end

  describe "#grade_for_course(course)" do
    it "returns the grade scheme element that matches the students score for the course" do
      gse = create(:grade_scheme_element, course: course, lowest_points: 80000)
      expect(student.grade_for_course(course)).to eq(gse)
    end
  end

  describe "#grade_level_for_course(course)" do
    it "returns the grade scheme level name that matches the student's score for the course" do
      gse = create(:grade_scheme_element, course: course, lowest_points: 80000, level: "Meh")
      expect(student.grade_level_for_course(course)).to eq("Meh")
    end
  end

  describe "#grade_letter_for_course(course)" do
    it "returns the grade scheme letter name that matches the student's score for the course" do
      gse = create(:grade_scheme_element, course: course, lowest_points: 80000, letter: "Q")
      expect(student.grade_letter_for_course(course)).to eq("Q")
    end
  end

  describe "#grades_released_for_course_this_week(course)" do
    let(:assignment_2) { create :assignment, course: course }

    it "returns the student's earned grades for a course this week" do
      grade_1 = create(:student_visible_grade, assignment: assignment, raw_points: 100, student: student, course: course, graded_at: Date.today - 10)
      grade_2 = create(:student_visible_grade, assignment: assignment_2, raw_points: 300, student: student, course: course, graded_at: Date.today)
      expect(student.grades_released_for_course_this_week(course)).to eq([grade_2])
    end
  end

  describe "#points_earned_for_course_this_week(course)" do
    let(:assignment_2) { create :assignment, course: course }

    it "returns the student's earned points for the course this week" do
      grade_1 = create(:student_visible_grade, assignment: assignment, raw_points: 100, student: student, course: course, graded_at: Date.today - 10)
      grade_2 = create(:student_visible_grade, assignment: assignment_2, raw_points: 300, student: student, course: course, graded_at: Date.today)
      expect(student.points_earned_for_course_this_week(course)).to eq(300)
    end
  end

  describe "#earned_badge_score_for_course(course)" do
    before do
      create(:earned_badge, student: student, course: course, badge: create(:badge, full_points: 100))
      create(:earned_badge, student: student, course: course, badge: create(:badge, full_points: 400))
    end

    it "returns the sum of the badge score for a student" do
      expect(student.earned_badge_score_for_course(course)).to eq(500)
    end

    it "does not include earned badges that have not yet been made student visible" do
      create(:earned_badge, student: student, course: course, grade: (create :in_progress_grade))
      expect(student.earned_badge_score_for_course(course)).to eq(500)
    end
  end

  describe "#earned_badges_for_course_this_week(course)" do
    it "returns the students' earned_badges for a course" do
      earned_badge_1 = create(:earned_badge, student: student, course: course, created_at: Date.today - 10)
      earned_badge_2 = create(:earned_badge, student: student, course: course)
      expect(student.earned_badges_for_course_this_week(course)).to eq([earned_badge_2])
    end
  end
end
