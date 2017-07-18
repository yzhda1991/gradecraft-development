describe BadgeProctor::Viewable do
  let(:course) { build(:course) }
  let(:badge) { build(:badge, course: course, visible: false) }
  let(:student) { create(:course_membership, course: course, role: :student).user }
  let(:professor) { create(:course_membership, role: "professor", course: course).user }

  describe "#viewable?" do
    subject { BadgeProctor.new(badge) }

    it "cannot be viewable if the badge is nil" do
      subject = BadgeProctor.new(nil)
      expect(subject).to_not be_viewable student, course: course
    end

    context "as a student" do
      it "cannot view the badge if it's not visible" do
        expect(subject).to_not be_viewable student, course: course
      end

      it "cannot view the badge if it's not part of the course" do
        allow(badge).to receive(:course_id).and_return 789
        expect(subject).to_not be_viewable student, course: course
      end

      it "can view the badge if it's visible" do
        badge.visible = true
        badge.save
        expect(subject).to be_viewable student, course: course
      end

      it "can view the badge if earned and the EarnedBadge is visible" do
        grade = create :student_visible_grade
        eb = create(:earned_badge,
          course: course,
          badge: badge,
          grade: grade,
          student: student)
        subject = BadgeProctor.new(badge)
        expect(subject).to be_viewable student, course: course
      end

      it "cannnot view the badge if earned but the EarnedBadge is invisible" do
        grade = create :in_progress_grade
        eb = create(:earned_badge,
          course: course,
          badge: badge,
          grade: grade,
          student: grade.student)
        subject = BadgeProctor.new(badge)
        expect(subject).to_not be_viewable eb.student, course: eb.course
      end

      context "with level in options" do
        it "is visible if the badge is earned for that level" do
          level = create(:level)
          eb = create(:earned_badge,
            course: course,
            badge: badge,
            level_id: level.id,
            student_visible: true,
            student: student)
          subject = BadgeProctor.new(badge)
          expect(subject).to be_viewable student,
            level: level, course: course
        end

        it "is not visible if the badge is earned but not for that level" do
          level = create(:level)
          eb = create(:earned_badge,
            course: course,
            badge: badge,
            student_visible: true)
          subject = BadgeProctor.new(badge)
          expect(subject).to_not be_viewable eb.student,
            level: level, course: eb.course
        end
      end
    end

    context "as staff" do
      it "can view the badge if they're an instructor for the course" do
        allow(professor).to receive(:is_staff?).with(course).and_return true
        expect(subject).to be_viewable professor, course: course
      end

      it "cannot view the badge if they're not an instructor for the course" do
        allow(professor).to receive(:is_staff?).with(course).and_return false
        expect(subject).to_not be_viewable professor, course: course
      end
    end
  end
end
