#spec/controllers/students_controller_spec.rb
require 'spec_helper'

describe StudentsController do

	context "as a professor" do 
		describe "GET index"
		describe "GET leaderboard"
		describe "GET syllabus"
		describe "GET timeline"
		describe "GET autocomplete_student_name"
		describe "GET course_progress"
		describe "GET badges"
		describe "GET predictor" 
		describe "GET scores_by_assignment" 
		describe "GET grade_index"  
		describe "GET recalculate" 
	end

	context "as a student" do 
		describe "GET syllabus" 
		describe "GET timeline" 
		describe "GET course_progress"
		describe "GET badges"
		describe "GET predictor"
		describe "GET scores_by_assignment"
		describe "GET course_progress"

		describe "protected routes" do
      [
        :index,
        :leaderboard,
        :autocomplete_student_name
      ].each do |route|
          it "#{route} redirects to root" do
            (get route).should redirect_to(:root)
          end
        end
    end

    describe "protected routes requiring id in params" do
      [
        :grade_index,
        :recalculate
      ].each do |route|
        it "#{route} redirects to root" do
        	pending
          (get route, {:id => "10"}).should redirect_to(:root)
        end
      end
    end

	end
end