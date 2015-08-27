require 'spec_helper'

describe Course do

  before do
    @course = build(:course)
  end

  subject { @course }

  it { is_expected.to respond_to("academic_history_visible")}
  it { is_expected.to respond_to("accepts_submissions")}
  it { is_expected.to respond_to("add_team_score_to_student")}
  it { is_expected.to respond_to("assignment_term")}
  it { is_expected.to respond_to("assignment_weight_close_at")}
  it { is_expected.to respond_to("assignment_weight_type")}
  it { is_expected.to respond_to("badge_set_id")}
  it { is_expected.to respond_to("badge_setting")}
  it { is_expected.to respond_to("badge_term")}
  it { is_expected.to respond_to("badge_use_scope")}
  it { is_expected.to respond_to("badges_value")}
  it { is_expected.to respond_to("challenge_term")}
  it { is_expected.to respond_to("character_profiles")}
  it { is_expected.to respond_to("check_final_grade")}
  it { is_expected.to respond_to("class_email")}
  it { is_expected.to respond_to("courseno")}
  it { is_expected.to respond_to("created_at")}
  it { is_expected.to respond_to("default_assignment_weight")}
  it { is_expected.to respond_to("end_date")}
  it { is_expected.to respond_to("fail_term")}
  it { is_expected.to respond_to("grade_scheme_id")}
  it { is_expected.to respond_to("grading_philosophy")}
  it { is_expected.to respond_to("graph_display")}
  it { is_expected.to respond_to("group_setting")}
  it { is_expected.to respond_to("group_term")}
  it { is_expected.to respond_to("homepage_message")}
  it { is_expected.to respond_to("in_team_leaderboard")}
  it { is_expected.to respond_to("location")}
  it { is_expected.to respond_to("lti_uid")}
  it { is_expected.to respond_to("max_assignment_types_weighted")}
  it { is_expected.to respond_to("max_assignment_weight")}
  it { is_expected.to respond_to("max_group_size")}
  it { is_expected.to respond_to("media_caption")}
  it { is_expected.to respond_to("media_credit")}
  it { is_expected.to respond_to("media_file")}
  it { is_expected.to respond_to("meeting_times")}
  it { is_expected.to respond_to("min_group_size")}
  it { is_expected.to respond_to("name")}
  it { is_expected.to respond_to("office")}
  it { is_expected.to respond_to("office_hours")}
  it { is_expected.to respond_to("pass_term")}
  it { is_expected.to respond_to("phone")}
  it { is_expected.to respond_to("point_total")}
  it { is_expected.to respond_to("predictor_setting")}
  it { is_expected.to respond_to("semester")}
  it { is_expected.to respond_to("start_date")}
  it { is_expected.to respond_to("status")}
  it { is_expected.to respond_to("tagline")}
  it { is_expected.to respond_to("team_challenges")}
  it { is_expected.to respond_to("team_leader_term")}
  it { is_expected.to respond_to("team_roles")}
  it { is_expected.to respond_to("team_score_average")}
  it { is_expected.to respond_to("team_setting")}
  it { is_expected.to respond_to("team_term")}
  it { is_expected.to respond_to("teams_visible")}
  it { is_expected.to respond_to("total_assignment_weight")}
  it { is_expected.to respond_to("twitter_handle")}
  it { is_expected.to respond_to("twitter_hashtag")}
  it { is_expected.to respond_to("updated_at")}
  it { is_expected.to respond_to("use_timeline")}
  it { is_expected.to respond_to("user_term")}
  it { is_expected.to respond_to("weight_term")}
  it { is_expected.to respond_to("year")}

  it { is_expected.to be_valid }

  it "is valid with an assignment, student, assignment_type, and course" do
    expect(build(:course)).to be_valid
  end

  it "returns an alphabetical list of students being graded" do
    student = create(:user, last_name: 'Zed')
    student.courses << @course
    student2 = create(:user, last_name: 'Alpha')
    student2.courses << @course
    expect(@course.students_being_graded).to eq([student2,student])
  end

  it "returns Pass and Fail as defaults for pass_term and fail_term" do
    expect(@course.pass_term).to eq("Pass")
    expect(@course.fail_term).to eq("Fail")
  end

  describe "#instructors_of_record" do
    it "returns all the staff who are instructors of record for the course" do
      membership = create :staff_course_membership, course: subject, instructor_of_record: true
      expect(subject.instructors_of_record).to eq [membership.user]
    end
  end

  describe "#instructors_of_record_ids=" do
    it "adds the instructors of record if they were not there before" do
      membership = create :staff_course_membership, course: subject
      subject.instructors_of_record_ids = [membership.user_id]
      expect(subject.instructors_of_record).to eq [membership.user]
    end

    it "removes the instructors of record that are not present" do
      membership = create :staff_course_membership, course: subject, instructor_of_record: true
      subject.instructors_of_record_ids = []
      expect(subject.instructors_of_record).to be_empty
    end
  end
end
