#spec/controllers/rubric_grades_controller_spec.rb
require 'spec_helper'

describe RubricGradesController do

	context "as a professor" do 
		describe "GET new"
		describe "GET edit"
		describe "GET create"
		describe "GET destroy"
		describe "GET show"
		describe "GET update" 
	end

	context "as a student" do 

		describe "protected routes" do
      [
        :new,
        :edit,
        :create, 
        :destroy,
        :show,
        :update
      ].each do |route|
          it "#{route} redirects to root" do
      			pending
            (get route).should redirect_to(:root)
          end
        end
    end

	end

end