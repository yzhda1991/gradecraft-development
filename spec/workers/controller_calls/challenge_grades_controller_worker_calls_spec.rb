require 'spec_helper'
require "set"

include ResqueJobSharedExamplesToolkit

# debug block
# puts assigns(:challenge_grade)
# puts assigns(:challenge_grade).valid?
# puts "team: #{assigns(:team)}"
# puts "current_course: #{assigns(:current_course)}"
# puts "add_team_score_to_student? #{assigns(:course).add_team_score_to_student?}"
# puts "students: #{assigns(:team).students}"

RSpec.describe ChallengeGradesController, type: :controller, background_job: true do
  include InQueueHelper
  before(:each) { ResqueSpec.reset! }

  let(:cache_everything) { course; team; challenge; challenge_grade; student1; student2; add_students_to_team; }
  let(:course) { create(:course_accepting_groups, add_team_score_to_student: true) }
  let(:team) { create(:team) }
  let(:challenge) { create(:challenge, course_id: course.id) }
  let(:challenge_grade) { create(:challenge_grade, challenge_id: challenge.id, team_id: team.id) }
  let(:student1) { create(:user) }
  let(:student2) { create(:user) }
  let(:students) { [ student1, student2] }
  let(:enroll_student) { create(:course_membership, user_id: student1.id, course_id: course.id, role: "student") }
  let(:professor) { create(:user) }
  let(:enroll_professor) { create(:course_membership, user_id: professor.id, course_id: course.id, role: "professor") }

  let(:batch_attributes) do
    [{user_id: student1.id, course_id: course.id},
     {user_id: student2.id, course_id: course.id}]
  end

  let(:add_students_to_team) do
    [ student1, student2 ].each do |student|
      create(:team_membership, team_id: team.id, student_id: student.id)
    end
  end

  before(:each) do
    session[:course_id] = course.id
    allow(controller).to receive(:current_course) { course }
    allow(professor).to receive(:admin?) { true } # let's call the prof an admin for now
    allow(controller).to receive(:scored_changed) { true }
    allow(request).to receive_message_chain(:format, :html?) { false } #increment_page_views 
    allow(challenge).to receive_message_chain(:challenge_grades, :create) { challenge_grade }
    allow(course).to receive(:add_team_score_to_student?) { true }
    allow(challenge_grade).to receive(:team).and_return team
    allow(team).to receive(:students).and_return students
    add_students_to_team
    enroll_and_login_professor
    allow(controller).to receive_message_chain(:current_student, :present?) { false }
  end

  context "triggering jobs as a student" do
    describe "PUT #update" do
      subject { put :update, request_attrs }
      let(:request_attrs) {{
        challenge_id: challenge.id,
        id: challenge_grade.id,
        challenge_grade: attributes_for(:challenge_grade, score: rand(10000000))
      }}

      it_behaves_like "a batch of successful resque jobs", 2, ScoreRecalculatorJob
    end
  end

  context "triggering jobs as a student" do
    describe "POST #create" do
      subject { post :create, request_attrs }
      let(:challenge_grade_attrs) {{
        score: rand(10000000),
        challenge_id: challenge.id,
        team_id: team.id
      }}
      let(:request_attrs) {{
        challenge_id: challenge.id,
        id: challenge_grade.id,
        challenge_grade: attributes_for(:challenge_grade, challenge_grade_attrs)
      }}

      it_behaves_like "a batch of successful resque jobs", 2, ScoreRecalculatorJob
    end
  end

  def enroll_and_login_professor
    allow(controller).to receive_messages(current_student: student1)
    enroll_professor
    login_user(professor)
    session[:course_id] = course.id
  end

  def enroll_and_login_student
    allow(controller).to receive_messages(current_student: student1)
    enroll_student
    login_user(student1)
    session[:course_id] = course.id
  end
end
