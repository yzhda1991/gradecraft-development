#spec/controllers/assignment_types_controller_spec.rb
require 'spec_helper'

describe AssignmentTypesController do

	context "as professor" do 
		describe "GET index"

		describe "GET show"

		describe "GET new"

		describe "GET edit"

		describe "POST create"

		describe "POST update"

		describe "GET sort"

		describe "GET export_scores"

		describe "GET export_all_scores"

		describe "GET all_grades"

		describe "GET destroy"

	end

	context "as student" do 

		describe "protected routes" do
      [
        :index,
        :new,
        :create,
        :sort,
        :export_all_scores

      ].each do |route|
          it "#{route} redirects to root" do
            (get route).should redirect_to(:root)
          end
        end
    end


    describe "protected routes requiring id in params" do
      [
        :edit,
        :show,
        :update,
        :destroy,
        :export_scores,
        :all_grades
      ].each do |route|
        it "#{route} redirects to root" do
          (get route, {:id => "1"}).should redirect_to(:root)
        end
      end
    end

	end

end