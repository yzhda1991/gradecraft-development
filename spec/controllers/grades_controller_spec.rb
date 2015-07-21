require 'spec_helper'

describe GradesController do
	
	context "as professor" do 
		
		describe "GET show"

		describe "GET edit"

		describe "GET update"

		describe "POST submit_rubric"

		describe "GET remove"

		describe "GET destroy"

		describe "GET self_log"

		describe "POST predict_score"

		describe "GET mass_edit"

		describe "POST mass_update"

		describe "GET group_edit"

		describe "POST group_update"

		describe "GET edit_status"

		describe "POST update_status"

		describe "GET import"

		describe "GET username_import"

		describe "GET email_import"

	end

	context "as student" do 

		describe "GET show"

		describe "POST predict_score"

		describe "POST self_log"

		describe "protected routes" do
      [
        :edit,
        :update,
        :submit_rubric,
        :remove,
        :destroy,
        :mass_edit,
        :mass_update,
        :group_edit,
        :group_update,
        :edit_status,
        :update_status,
        :import,
        :username_import,
        :email_import
      ].each do |route|
          it "#{route} redirects to root" do
          	pending
            (get route).should redirect_to(:root)
          end
        end
    end
	end
end
