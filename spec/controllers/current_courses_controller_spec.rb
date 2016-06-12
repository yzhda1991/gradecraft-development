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

  describe "GET change" do
    it "switches the course context" do
      get :change, course_id: another_course.id
      expect(response).to redirect_to(root_url)
      expect(session[:course_id]).to eq(another_course.id)
    end

    it "records the course login event if the course changed" do
      expect(subject).to receive(:record_course_login_event)
      get :change, course_id: another_course.id.to_s
    end

    it "does not record the course login event if the course does not change" do
      expect(subject).to_not receive(:record_course_login_event)
      get :change, course_id: course.id.to_s
    end

    it "stores the course to the current course for the user" do
      get :change, course_id: another_course.id
      expect(user.reload.current_course_id).to eq another_course.id
    end
  end

end
