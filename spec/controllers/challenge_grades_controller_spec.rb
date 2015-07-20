#spec/controllers/challenge_grades_controller_spec.rb
require 'spec_helper'

describe ChallengeGradesController do

	context "as professor" do 

		describe "GET index"

		describe "GET show"

		describe "GET new"

		describe "GET edit"

		describe "GET mass_edit"

		describe "POST create"

		describe "POST update"

		describe "POST mass_update"

		describe "GET edit_status"

		describe "POST update_status"

		describe "GET destroy"

	end

	context "as student" do 

		describe "GET show"

		describe "protected routes" do
			
      [
        :index,
        :new,
        :create

      ].each do |route|
          it "#{route} redirects to root" do
      			pending
            (get route).should redirect_to(:root)
          end
        end
    end


    describe "protected routes requiring id in params" do

      [
        :edit,
        :mass_edit,
        :mass_update,
        :edit_status,
        :update_status,
        :update,
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
      		pending
          (get route, {:id => "1"}).should redirect_to(:root)
        end
      end
    end

	end
end