#spec/controllers/analytics_controller_spec.rb
require 'spec_helper'

describe AnalyticsController do

	context "as a professor" do 

		describe "GET index"

		describe "GET students"

		describe "GET staff"

		describe "GET all_events"

		describe "GET top_10"

		describe "GET per_assign"

		describe "GET teams"

		describe "GET role_events"

		describe "GET assignment_events"

		describe "GET login_frequencies"

		describe "GET role_login_frequencies"

		describe "GET login_events"

		describe "GET login_role_events"

		describe "GET all_pageview_events"

		describe "GET all_role_pageview_events"

		describe "GET all_user_pageview_events"

		describe "GET pageview_events"

		describe "GET role_pageview_events"

		describe "GET user_pageview_events"

		describe "GET prediction_averages"

		describe "GET assignment_prediction_averages"

		describe "GET export"

	end

	context "as a student" do 

	   describe "protected routes" do
          [
            :index,
            :students,
            :staff,
            :all_events, 
            :top_10,
            :per_assign,
            :teams,
            :role_events,
            :assignment_events,
            :login_frequencies,
            :role_login_frequencies,
            :login_events,
            :login_role_events,
            :all_pageview_events,
            :all_role_pageview_events, 
            :all_user_pageview_events,
            :pageview_events,
            :role_pageview_events,
            :user_pageview_events,
            :prediction_averages,
            :assignment_prediction_averages,
            :export

          ].each do |route|
              it "#{route} redirects to root" do
                (get route).should redirect_to(:root)
              end
            end
        end

	end

end