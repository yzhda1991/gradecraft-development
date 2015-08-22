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
      @earned_badges = create_list(:earned_badge, 3, course: @course, student: @student, student_visible: true)
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
      @earned_badges = create_list(:earned_badge, 3, course: @course, student: @student, student_visible: true)
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

  context "instructor is editing the grade for a student's submission", working: true do
    before(:each) do
      # Pulled in for highest-level before(:each)
      # @course = create(:course)
      # @student = create(:user)
      # create(:course_membership, course: @course, user: @student)
      # @assignment = create(:assignment, course: @course)
      # @grade = create(:grade, assignment: @assignment, assignment_type: @assignment.assignment_type, course: @course, student: @student)

      @single_badge = create(:badge, course: @course, can_earn_multiple_times: false)
      @multi_badge = create(:badge, course: @course, can_earn_multiple_times: true)

      @another_assignment = create(:assignment, course: @course)
      @another_grade = create(:grade, assignment: @another_assignment, assignment_type: @another_assignment.assignment_type, course: @course, student: @student)
    end

    it "should not see badges that aren't included in the current course" do
      @some_other_course = create(:course)
      @some_other_assignment = create(:assignment, course: @some_other_course)
      @some_other_grade = create(:grade, assignment: @some_other_assignment, assignment_type: @some_other_assignment.assignment_type, course: @some_other_course, student: @student)
      @some_other_badge = create(:badge, course: @some_other_course)

      expect(@student.earnable_course_badges_for_grade(@grade)).not_to include(@some_other_badge)
    end

    it "should see badges for the current course" do
      EarnedBadge.destroy_all course_id: @course[:id]
      expect(@student.earnable_course_badges_for_grade(@grade)).to include([@single_badge, @multi_badge])
    end

    it "should show course badges that the student has yet to earn", broken: true do
      EarnedBadge.destroy_all course_id: @course[:id]
      pp EarnedBadge.all
      pp "Student id: #{@student.id}"
      pp "Course ID: #{@course.id}"
      pp "Grade ID: #{@grade.id}"
      pp "Single Badge ID: #{@single_badge}"
      pp "Multi Badge ID: #{@multi_badge}"
      pp @student.earnable_course_badges_for_grade(@grade).to_sql
      pp @student.earnable_course_badges_for_grade(@grade)
      pp "Total Badges: #{Badge.all.count}"
      expect(@student.earnable_course_badges_for_grade(@grade)).to include(@single_badge, @multi_badge)
    end

    it "should not show badges that the student has earned for other grades, and can't be earned multiple times" do
      @student.earn_badge_for_grade(@single_badge, @another_grade) # earn the badge on another grade
      expect(@student.earnable_course_badges_for_grade(@grade)).not_to include(@single_badge)
    end

    it "should show badges that the student has earned but CAN be earned multiple times", broken: true do
      @student.earn_badge_for_grade(@multi_badge, @grade)
      expect(@student.earnable_course_badges_for_grade(@grade)).to include(@multi_badge)
    end

    it "should show badges that the student has earned for the current grade, even if it can't be earned multiple times" do
      @student.earn_badge_for_grade(@single_badge, @grade)
      expect(@student.earnable_course_badges_for_grade(@grade)).to include(@single_badge)
    end
  end

  context "user earns just one badge", working: true do
    before(:each) do
      @student = create(:user)
      @current_course = create(:course)
      @current_assignment = create(:assignment, course: @current_course)
      @current_grade = create(:grade, assignment: @current_assignment, assignment_type: @current_assignment.assignment_type, course: @current_course, student: @student)
      @current_badge = create(:badge, course: @current_course)
    end

    it "should create a valid earned badge" do
      expect(@student.earn_badge(@current_badge).class).to eq(EarnedBadge)
      expect(@student.earn_badge(@current_badge).valid?).to be true
    end

    it "should not error out when earning one badge" do
      expect(@student.earn_badge(@current_badge)).not_to raise_error
    end

    it "should choke on an array of badges" do
      expect(@student.earn_badge([@current_badge])).to raise_error(TypeError)
    end
  end

  context "student_invisible_badges" do
    it "should return invisible badges for which the student has earned a badge" do
      @invisible_badges = create_list(:badge, 2, course: @course, visible: false)
      @student.earn_badges(@invisible_badges)
      @badges_earned_by_id = @student.student_invisible_badges(@course)
      expect(@badges_earned_by_id).to eq(@invisible_badges)
    end

    it "should not return visible badges for which the student has earned a badge" do
      @visible_badges = create_list(:badge, 2, course: @course, visible: true)
      @student.earn_badges(@visible_badges)
      @badges_earned_by_id = @student.student_invisible_badges(@course).sort_by(&:id)
      expect(@badges_earned_by_id).not_to eq(@visible_badges.sort_by(&:id))
    end
  end

end
