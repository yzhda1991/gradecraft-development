describe FlaggedUser do
  let(:course) { build :course }
  let!(:professor) { create :user, courses: [course], role: :professor }
  let!(:student) { create :user, courses: [course], role: :student }

  context "validations" do
    subject do
      FlaggedUser.new course_id: course.id,
        flagger_id: professor.id,
        flagged_id: student.id
    end

    it "a course is required" do
      subject.course_id = 123456
      expect(subject).to_not be_valid
      expect(subject.errors[:course]).to include "can't be blank"
    end

    it "a flagger is required" do
      subject.flagger_id = 123456
      expect(subject).to_not be_valid
      expect(subject.errors[:flagger]).to include "can't be blank"
    end

    it "a flagged user is required" do
      subject.flagged_id = 123456
      expect(subject).to_not be_valid
      expect(subject.errors[:flagged]).to include "can't be blank"
    end

    it "the flagger must belong to the course" do
      CourseMembership.where(course_id: course.id, user_id: professor.id).destroy_all
      expect(subject).to_not be_valid
      expect(subject.errors[:flagger]).to include "must belong to the course"
    end

    it "the flagged must belong to the course" do
      CourseMembership.where(course_id: course.id, user_id: student.id).destroy_all
      expect(subject).to_not be_valid
      expect(subject.errors[:flagged]).to include "must belong to the course"
    end

    it "does not allow a student to be flagged by another student" do
      another_student = create :user, courses: [course], role: :student
      subject = FlaggedUser.new course_id: course.id,
        flagger_id: another_student.id,
        flagged_id: student.id
      expect(subject).to_not be_valid
      expect(subject.errors[:flagger]).to include "must be a staff member"
    end
  end

  describe ".flag!" do
    it "creates a relationship between staff and a student" do
      FlaggedUser.flag!(course, professor, student.id)
      result = FlaggedUser.last
      expect(result.course_id).to eq course.id
      expect(result.flagger_id).to eq professor.id
      expect(result.flagged_id).to eq student.id
    end
  end

  describe ".for_course" do
    it "returns all the flagged users for a specific course" do
      course_flagged_user = create(:flagged_user, flagger: professor, flagged: student, course: course)
      another_course = create(:course)
      another_professor = create :course_membership, :professor, course: another_course,
        user: professor
      another_student = create :course_membership, :student, course: another_course,
        user: student
      create(:flagged_user, flagger: another_professor.user,
             flagged: another_student.user, course: another_course)
      results = FlaggedUser.for_course(course)
      expect(results).to eq [course_flagged_user]
    end
  end

  describe ".for_flagged" do
    it "returns all the flagged users for a specific flagged user" do
      student_flagged_user = create(:flagged_user, flagger: professor,
                                    flagged: student, course: course)
      another_student = create(:user, courses: [course], role: :student)
      another_flagged_user = create(:flagged_user, flagger: professor,
                                    flagged: another_student, course: course)
      results = FlaggedUser.for_flagged(student)
      expect(results).to eq [student_flagged_user]
    end
  end

  describe ".for_flagger" do
    it "returns all the flagged users for a specific flagger user" do
      student_flagged_user = create(:flagged_user, flagger: professor,
                                    flagged: student, course: course)
      another_flagger = create(:course_membership, :professor, course: course).user
      another_flagged_user = create(:flagged_user, flagger: another_flagger,
                                    flagged: student, course: course)
      results = FlaggedUser.for_flagger(professor)
      expect(results).to eq [student_flagged_user]
    end
  end

  describe ".unflag!" do
    before { FlaggedUser.flag!(course, professor, student.id) }

    it "deletes the relationship between staff and student" do
      FlaggedUser.unflag!(course, professor, student.id)
      expect(FlaggedUser.count).to be_zero
    end
  end

  describe ".flagged?" do
    it "returns true if the user is flagged by the flagger for the course" do
      FlaggedUser.flag!(course, professor, student.id)
      expect(FlaggedUser.flagged? course, professor, student.id).to eq true
    end

    it "returns false if the user is not flagged by the flagger for the course" do
      expect(FlaggedUser.flagged? course, professor, student.id).to eq false
    end
  end

  describe ".flagged" do
    it "returns the users who were flagged by a user for a course" do
      FlaggedUser.flag!(course, professor, student.id)
      expect(FlaggedUser.flagged(course, professor)).to eq [student]
    end
  end

  describe ".toggle!" do
    it "creates a relationship between staff and a student if it doesn't exist" do
      FlaggedUser.toggle!(course, professor, student.id)
      expect(FlaggedUser.count).to eq 1
    end

    it "deletes the relationship between staff and student if it does exist" do
      FlaggedUser.flag!(course, professor, student.id)
      FlaggedUser.toggle!(course, professor, student.id)
      expect(FlaggedUser.count).to eq 0
    end
  end
end
