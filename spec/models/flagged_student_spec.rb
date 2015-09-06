require "active_record_spec_helper"

describe FlaggedUser do
  let(:course) { create :course }
  let(:professor) { create :user }
  let(:student) { create :user }

  before do
    create :course_membership, course: course, user: professor, role: "professor"
    create :course_membership, course: course, user: student, role: "student"
  end

  context "validations" do
    subject do
      FlaggedUser.new course_id: course.id,
        flagger_id: professor.id,
        flagged_id: student.id
    end

    it "a course is required" do
      subject.course_id = 123
      expect(subject).to_not be_valid
      expect(subject.errors[:course]).to include "can't be blank"
    end

    it "a flagger is required" do
      subject.flagger_id = 123
      expect(subject).to_not be_valid
      expect(subject.errors[:flagger]).to include "can't be blank"
    end

    it "a flagged user is required" do
      subject.flagged_id = 123
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

    xit "does not allow a student to be flagged by another student"
  end

  it "creates a relationship between staff and a student" do
    FlaggedUser.flag!(course, professor, student.id)
    result = FlaggedUser.last
    expect(result.course_id).to eq course.id
    expect(result.flagger_id).to eq professor.id
    expect(result.flagged_id).to eq student.id
  end
end
