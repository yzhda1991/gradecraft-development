describe CourseMembership do
  let(:course_membership) { build(:course_membership, :student, course: course, user: student) }
  let(:course) { build(:course) }
  let(:student) { build(:user) }
  let!(:gse) { create(:grade_scheme_element, course: course, lowest_points: 8000) }

  describe "#recalculate_and_update_student_score" do
    subject { course_membership.recalculate_and_update_student_score }

    it "updates the score with the recalculated one" do
      allow(course_membership).to receive(:recalculated_student_score) { 5000 }
      expect(course_membership).to receive(:update_attribute).with(:score, 5000)
      subject
    end

    it "modifies the score attribute" do
      allow(course_membership).to receive(:recalculated_student_score) { 8200 }
      subject
      expect(course_membership.score).to eq(8200)
    end
  end

  describe "#recalculated_student_score" do
    before do
      allow(course_membership).to receive_messages({
        assignment_type_totals_for_student: 500,
        student_earned_badge_score: 600,
        conditional_student_team_score: 700
      })
    end

    it "adds the relevant components of the student score" do
      expect(course_membership.recalculated_student_score).to eq(1800)
    end
  end

  describe "#check_and_update_student_earned_level" do
    subject { course_membership.check_and_update_student_earned_level }

    it "updates the earned level value" do
      expect(course_membership.earned_grade_scheme_element_id).to eq(nil)
      allow(course_membership).to receive(:score) { 8200 }
      subject
      expect(course_membership.reload.earned_grade_scheme_element_id).to eq(gse.id)
    end
  end

  describe "#earned_grade_scheme_element" do
    let!(:low_gse) { create(:grade_scheme_element, course: course, lowest_points: 7000) }
    let!(:high_gse) { create(:grade_scheme_element, course: course, lowest_points: 9001) }

    it "returns the element that matches the highest points the student has earned" do
      allow(course_membership).to receive(:score) { 8200 }
      expect(course_membership.earned_grade_scheme_element).to eq(gse)
    end

    it "does not return an element if it is still locked" do
      badge = create(:badge, course: course)
      create(:unlock_condition,
        condition_id: badge.id,
        condition_type: "Badge",
        condition_state: "Earned",
        unlockable_id: gse.id,
        unlockable_type: "GradeSchemeElement"
      )
      allow(course_membership).to receive(:score) { 8200 }
      expect(course_membership.earned_grade_scheme_element).to eq(low_gse)
    end
  end

  describe "#assignment_type_totals_for_student" do
    subject { course_membership.instance_eval { assignment_type_totals_for_student }}
    let(:assignment_type1) { build(:assignment_type) }
    let(:assignment_type2) { build(:assignment_type) }

    before(:each) { course.assignment_types = [ assignment_type1, assignment_type2 ] }

    context "both assignment types have scores" do
      it "returns the sum of the scores" do
        allow(assignment_type1).to receive(:visible_score_for_student) { 900 }
        allow(assignment_type2).to receive(:visible_score_for_student) { 1800 }
        expect(subject).to eq(2700)
      end
    end

    context "one of the assignment types has a nil visible score" do
      it "compacts out the nil and sums only the valid scores" do
        allow(assignment_type1).to receive(:visible_score_for_student) { nil }
        allow(assignment_type2).to receive(:visible_score_for_student) { 1400 }
        expect(subject).to eq(1400)
      end
    end

    context "there are no assignment types" do
      it "returns zero anyway" do
        course.assignment_types = []
        expect(subject).to eq(0)
      end
    end

    context "some error occurs in the collect block" do
      before(:each) do
        allow(assignment_type1).to receive(:visible_score_for_student).and_raise "a strange error that abandons the other number"
        allow(assignment_type2).to receive(:visible_score_for_student) { 1400 }
      end

      it "rescues out to zero for posterity's sake" do
        expect(subject).to eq(0)
      end

      it "logs an error with full object attributes" do
        expect(course_membership).to receive(:log_error_with_attributes)
        subject
      end
    end
  end

  describe "#conditional_student_team_score" do
    subject { course_membership.instance_eval { conditional_student_team_score }}
    context "include_team_score? is true" do
      it "returns the student_team_score" do
        allow(course_membership).to receive(:include_team_score?) { true }
        allow(course_membership).to receive(:student_team_score) { 85132 }
        expect(subject).to eq(85132)
      end
    end

    context "include_team_score? is false" do
      it "returns zero" do
        allow(course_membership).to receive(:include_team_score?) { false }
        expect(subject).to eq(0)
      end
    end
  end

  describe "#student_earned_badge_score" do
    subject { course_membership.instance_eval { student_earned_badge_score }}

    context "student's earned badge score for the course is nil" do
      it "returns zero" do
        allow(student).to receive(:earned_badge_score_for_course) { nil }
        expect(subject).to eq(0)
      end
    end

    context "student's earned badge score for the course raises an error" do
      before(:each) do
        allow(student).to receive(:earned_badge_score_for_course).and_raise "some error"
      end

      it "rescues out to zero" do
        expect(subject).to eq(0)
      end

      it "logs an error with full object attributes" do
        expect(course_membership).to receive(:log_error_with_attributes)
        subject
      end
    end

    context "student has an earned badge score for the course" do
      it "returns the earned badge score" do
        allow(student).to receive(:earned_badge_score_for_course) { 400 }
        expect(subject).to eq(400)
      end
    end
  end

  describe "#student_team_score" do
    subject { course_membership.instance_eval { student_team_score }}

    context "user doesn't have a team for the course" do
      it "returns zero" do
        allow(student).to receive(:team_for_course) { nil }
        expect(subject).to eq(0)
      end
    end

    context "user#team_for_course raises an error" do
      before(:each) do
        allow(student).to receive(:team_for_course).and_raise "some weird exception"
      end

      it "rescues out to zero" do
        expect(subject).to eq(0)
      end

      it "logs an error with full object attributes" do
        expect(course_membership).to receive(:log_error_with_attributes)
        subject
      end
    end

    context "user has a team for the course but no score" do
      it "returns zero" do
        allow(student).to receive_message_chain(:team_for_course, :score) { nil }
        expect(subject).to eq(0)
      end
    end

    context "user has a team for the course that has a score" do
      it "uses the team score" do
        allow(student).to receive_message_chain(:team_for_course, :score) { 45000 }
        expect(subject).to eq(45000)
      end
    end
  end

  describe "#include_team_score" do
    subject { course_membership.instance_eval { include_team_score? }}
    let(:add_team_score_false) { allow(course).to receive(:add_team_score_to_student?) { false }}
    let(:add_team_score_true) { allow(course).to receive(:add_team_score_to_student?) { true }}
    let(:use_team_average_false) { allow(course).to receive(:team_score_average) { false }}
    let(:use_team_average_true) { allow(course).to receive(:team_score_average) { true }}

    # course.add_team_score_to_student? and not course.team_score_average
    context "course adds team score to student but uses the team average" do
      it "returns false" do
        add_team_score_true && use_team_average_true
        expect(subject).to be_falsey
      end
    end

    context "course doesn't add team score but isn't using the team average" do
      it "returns false" do
        add_team_score_false && use_team_average_false
        expect(subject).to be_falsey
      end
    end

    context "course doesn't add team score and is using the team average" do
      it "returns false" do
        add_team_score_false && use_team_average_true
        expect(subject).to be_falsey
      end
    end

    context "course adds team score and isn't using the team average" do
      it "returns true" do
        add_team_score_true && use_team_average_false
        expect(subject).to be_truthy
      end
    end
  end
end
