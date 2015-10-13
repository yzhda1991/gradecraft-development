require 'spec_helper'
require "set"

include ResqueJobSharedExamplesToolkit

RSpec.shared_examples "a successful resque job being tested" do |job_klass|
  it "increases the queue size by one" do
    expect{ subject }.to change { queue(job_klass).size }.by(1)
  end

  it "queues the job" do
    subject
    puts assigns(:challenge_grade)
    puts assigns(:challenge_grade).valid?
    puts "team: #{assigns(:team)}"
    puts "scored_changed: #{assigns(:scored_changed)}"
    puts "current_course: #{assigns(:current_course)}"
    puts "add_team_score_to_student? #{assigns(:current_course).add_team_score_to_student?}"
    puts "students: #{assigns(:team).students}"
    assigns(:team).students.each {|student| puts student }
    expect(job_klass).to have_queued(job_attributes)
  end

  it "builds a new #{job_klass}" do
    subject
    expect(assigns(job_klass.to_s.underscore.to_sym).class).to eq(job_klass)
  end
end

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

  context "triggering jobs as a student" do
    describe "PUT #self_log" do
      subject { put :update, request_attrs }
      let(:request_attrs) {{
        challenge_id: challenge.id,
        id: challenge_grade.id,
        challenge_grade: attributes_for(:challenge_grade, score: rand(10000000))
      }}

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
      end
      before(:each) do
        add_students_to_team
        enroll_and_login_professor
        allow(controller).to receive_message_chain(:current_student, :present?) { false }
      end

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
