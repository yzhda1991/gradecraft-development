#spec/controllers/rubrics_controller_spec.rb
require 'spec_helper'

describe RubricsController do

	context "as a professor" do 
		describe "GET design"
		describe "GET create"
		describe "GET destroy"
		describe "GET show"
		describe "GET update"
		describe "GET existing_metrics"
		describe "GET course_badges" 
	end

	context "as a student" do 
		describe "protected routes" do
      [
        :design,
        :create, 
        :destroy,
        :show,
        :update,
        :existing_metrics,
        :course_badges
      ].each do |route|
          it "#{route} redirects to root" do
      			pending
            (get route).should redirect_to(:root)
          end
        end
    end

	end
end