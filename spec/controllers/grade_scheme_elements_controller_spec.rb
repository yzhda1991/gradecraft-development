#spec/controllers/grade_scheme_elements_controller_spec.rb
require 'spec_helper'

describe GradeSchemeElementsController do

	context "as professor" do 
		
		describe "GET index"

		describe "GET mass_edit"

		describe "GET mass_update"

	end

	context "as student" do 

		describe "protected routes" do
      [
        :index,
        :mass_edit,
        :mass_update

      ].each do |route|
          it "#{route} redirects to root" do
            (get route).should redirect_to(:root)
          end
        end
    end
	end
end