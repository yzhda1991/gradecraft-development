# spec/models/user_spec.rb

require 'spec_helper'

describe User do
  before(:each) do
    @course = create(:course)
    @student = create(:user)
    create(:course_membership, course: @course, user: @student)
    @assignment = create(:assignment, course: @course)
    @grade = create(:grade, assignment: @assignment, assignment_type: @assignment.assignment_type, course: @course, student: @student)
  end

  describe ".find_by_insensitive_email" do
    it "should return the user no matter what the case the email address is in" do
      expect(User.find_by_insensitive_email(@student.email.upcase)).to eq @student
    end
  end

  describe ".students_auditing" do
    let(:student_being_audited) { create(:user) }
    before do
      create(:course_membership, course: @course, user: student_being_audited, auditing: true)
    end

    it "returns all the students that are being audited" do
      result = User.students_auditing(@course)
      expect(result.pluck(:id)).to eq [student_being_audited.id]
    end

    context "with a team" do
      let(:student_in_team) { create :user }
      let(:team) { create :team, course: @course }
      before do
        create(:course_membership, course: @course, user: student_in_team, auditing: true)
        team.students << student_in_team
      end

      it "returns only students in the team that are being audited" do
        result = User.students_auditing(@course, team)
        expect(result.pluck(:id)).to eq [student_in_team.id]
      end
    end
  end

  describe ".students_being_graded" do
    let(:student_not_being_graded) { create(:user) }
    before do
      create(:course_membership, course: @course, user: student_not_being_graded, auditing: true)
    end

    it "returns all the students that are being graded" do
      result = User.students_being_graded(@course)
      expect(result.pluck(:id)).to eq [@student.id]
    end

    context "with a team" do
      let(:student_in_team) { create :user }
      let(:team) { create :team, course: @course }
      before do
        create(:course_membership, course: @course, user: student_in_team)
        team.students << student_in_team
      end

      it "returns only students in the team that are being graded" do
        result = User.students_being_graded(@course, team)
        expect(result.pluck(:id)).to eq [student_in_team.id]
      end
    end
  end

  describe ".students_by_team" do
    let(:team) { create :team, course: @course }
    before do
      team.students << @student
    end

    it "returns only students in the team" do
      result = User.students_by_team(@course, team)
      expect(result.pluck(:id)).to eq [@student.id]
    end
  end

  describe "#activated?" do
    it "is activated when the activation state is active" do
      user = build :user, activation_state: "active"
      expect(user).to be_activated
    end

    it "is not activated when the activation state is pending" do
      user = build :user, activation_state: "pending"
      expect(user).to_not be_activated
    end
  end

  describe "#self_reported_done?" do
    it "is not self reported if there are no grades" do
      expect(@student).to_not be_self_reported_done(@assignment)
    end

    it "is self reported if there is at least one graded grade" do
      @grade.update_attribute :status, "Graded"
      expect(@student).to be_self_reported_done(@assignment)
    end
  end

  context "validations" do
    it "requires the password confirmation to match" do
      user = User.new password: "test", password_confirmation: "blah"
      expect(user).to_not be_valid
      expect(user.errors[:password_confirmation]).to include "doesn't match Password"
    end

    it "requires that there is a password confirmation" do
      @student.password = "test"
      expect(@student).to_not be_valid
      expect(@student.errors[:password_confirmation]).to include "can't be blank"
    end
  end

  context "ordering" do
    it "should return users alphabetical by last name" do
      User.destroy_all
      student = create(:user, last_name: 'Zed')
      student2 = create(:user, last_name: 'Alpha')
      User.all.should eq([student2,student])
    end
  end

  context "earn_badges" do
    it "should be able to earn badges" do
      @badges = create_list(:badge, 2, course: @course)
      @student.earn_badges(@badges)
      @badges_earned = @student.earned_badges.collect {|e| e.badge }.sort_by(&:id)
      expect(@badges_earned).to eq(@badges.sort_by(&:id))
    end
  end

  context "student_visible_earned_badges" do
    it "should know which badges a student has earned" do
      @earned_badges = create_list(:earned_badge, 3, course: @course, student: @student)
      expect(@student.student_visible_earned_badges(@course)).to eq(@earned_badges)
    end

    it "should not select non-visible student badges" do
      @earned_badges = create_list(:earned_badge, 3, course: @course, student: @student, student_visible: false)
      expect(@student.student_visible_earned_badges(@course)).to be_empty
    end

    it "should not return unearned badges as earned badges" do
      @unearned_badges = create_list(:badge, 2, course: @course)
      @visible_earned_badges = create_list(:earned_badge, 3, course: @course, student: @student)
      @unique_earned_badges = @student.student_visible_earned_badges(@course)
      expect(@unique_earned_badges).not_to include(*@unearned_badges)
    end
  end

  context "unique_student_earned_badges" do
    before(:each) do
      @earned_badges = create_list(:earned_badge, 3, course: @course, student: @student)
      @sorted_badges = @student.earned_badges.collect(&:badge).sort_by(&:id).flatten
      @badges_unearned = create_list(:badge, 2, course: @course)
    end

    it "should know which badges are unique to those student earned badges" do
      @student.unique_student_earned_badges(@course).each
      expect(@student.unique_student_earned_badges(@course)).to eq(@sorted_badges)
    end

    it "should not return badges associated with student-unearned badges" do
      expect(@student.unique_student_earned_badges(@course)).not_to include(*@badges_unearned)
    end
  end

  context "student_visible_unearned_badges" do
    before(:each) do
      @badges = create_list(:badge, 2, course: @course, visible: true)
    end

    it "should know which badges a student has yet to earn" do
      expect(@student.student_visible_unearned_badges(@course)).to eq(@badges.flatten)
    end

    it "should not return earned badges as unearned ones" do
      @earned_badges = create_list(:earned_badge, 2, course: @course, student: @student)
      expect(@student.student_visible_unearned_badges(@course)).not_to include(*@earned_badges)
    end
  end

  context "student_invisible_badges" do
    it "should return invisible badges for which the student has earned a badge" do
      @invisible_badges = create_list(:badge, 2, course: @course, visible: false)
      @student.earn_badges(@invisible_badges)
      @badges_earned_by_id = @student.student_invisible_badges(@course).sort_by(&:id)
      expect(@badges_earned_by_id).to eq(@invisible_badges.sort_by(&:id))
    end

    it "should not return visible badges for which the student has earned a badge" do
      @visible_badges = create_list(:badge, 2, course: @course, visible: true)
      @student.earn_badges(@visible_badges)
      @badges_earned_by_id = @student.student_invisible_badges(@course).sort_by(&:id)
      expect(@badges_earned_by_id).not_to eq(@visible_badges.sort_by(&:id))
    end
  end

end
