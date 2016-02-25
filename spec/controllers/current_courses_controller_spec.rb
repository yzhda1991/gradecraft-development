require "rails_spec_helper"

describe CurrentCoursesController do
  let(:course) { create :course }
  let(:another_course) { create :course }
  let(:user) { create :user }

  before do
    user.courses << [course, another_course]
    login_user(user)
    session[:course_id] = course.id
    allow(Resque).to receive(:enqueue).and_return(true)
  end

  describe "POST change" do
    it "switches the course context" do
      post :change, course_id: another_course.id
      expect(response).to redirect_to(root_url)
      expect(session[:course_id]).to eq(another_course.id)
    end

    it "logs the course login event if the course changed" do
      expect(subject).to receive(:log_course_login_event)
      post :change, course_id: another_course.id.to_s
    end

    it "does not log the course login event if the course does not change" do
      expect(subject).to_not receive(:log_course_login_event)
      post :change, course_id: course.id.to_s
    end

    it "stores the course to the current course for the user" do
      post :change, course_id: another_course.id
      expect(user.reload.current_course_id).to eq another_course.id
    end
  end

end
