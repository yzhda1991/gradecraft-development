#spec/controllers/current_courses_controller_spec.rb
require 'spec_helper'

describe CurrentCoursesController do
	
	before do
    @course = create(:course)
    @course_2 = create(:course)
    @user = create(:user)
    @user.courses << [@course, @course_2]
    
    login_user(@user)
    session[:course_id] = @course.id
    allow(EventLogger).to receive(:perform_async).and_return(true)
  end

  describe "POST change" do 
  	it "switches the course context" do
	  	post :change, :course_id => @course_2.id
	  	response.should redirect_to(root_url)
	  	session[:course_id].should eq(@course_2.id)
	  end
	end

end