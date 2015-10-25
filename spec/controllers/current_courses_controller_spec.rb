require 'spec_helper'

describe CurrentCoursesController do
  before do
    course = create(:course)
    @course_2 = create(:course)
    user = create(:user)
    user.courses << [course, @course_2]

    login_user(user)
    session[:course_id] = course.id
    allow(Resque).to receive(:enqueue).and_return(true)
  end

  describe "POST change" do
    it "switches the course context" do
      post :change, :course_id => @course_2.id
      expect(response).to redirect_to(root_url)
      expect(session[:course_id]).to eq(@course_2.id)
    end
  end

end
