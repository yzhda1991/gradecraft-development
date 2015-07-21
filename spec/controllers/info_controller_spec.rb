#spec/controllers/info_controller_spec.rb
require 'spec_helper'

describe InfoController do

	context "as a professor" do 

		describe "GET dashboard"
		describe "GET timeline_events"
		describe "GET class_badges"
		describe "GET grading_status"
		describe "GET resubmissions"
		describe "GET ungraded_submissions"
		describe "GET gradebook"
		describe "GET final_grades"
		describe "GET research_gradebook"
		describe "GET choices"
		describe "GET all_grades"

	end

	context "as a student" do 

		describe "GET dashboard"

		describe "GET timeline_events"
		
    describe "protected routes" do
      [
        :class_badges,
        :grading_status,
        :resubmissions,
        :ungraded_submissions,
        :gradebook,
        :final_grades,
        :research_gradebook,
        :choices,
        :all_grades
      ].each do |route|
        it "#{route} redirects to root" do
          (get route).should redirect_to(:root)
        end
      end
    end

	end

end