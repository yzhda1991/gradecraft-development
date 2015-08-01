#spec/controllers/analytics_events_controller_spec.rb
require 'spec_helper'

#TODO: Need to add https://github.com/leshill/resque_spec

describe AnalyticsEventsController do
	context "as a professor" do 

    before do
      @course = create(:course)
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
      @challenge = create(:challenge, course: @course)
      @course.challenges << @challenge
      @challenges = @course.challenges
      @student = create(:user)
      @student.courses << @course
      @team = create(:team, course: @course)
      @team.students << @student
      @teams = @course.teams

      login_user(@professor)
      session[:course_id] = @course.id
      allow(EventLogger).to receive(:perform_async).and_return(true)
    end

		describe "POST predictor_event" do  
      pending
    end

		describe "POST tab_select_event" do  
      pending
    end

	end

	context "as a student" do 

    before do
      @course = create(:course)
      @student = create(:user)
      @student.courses << @course

      login_user(@student)
      session[:course_id] = @course.id
      allow(EventLogger).to receive(:perform_async).and_return(true)
    end

	  describe "POST predictor_event" do  
      pending
    end

		describe "POST tab_select_event" do  
      pending
    end

	end
end