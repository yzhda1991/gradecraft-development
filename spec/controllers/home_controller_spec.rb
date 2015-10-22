require 'spec_helper'

describe HomeController do
  let(:course) { create(:course) }
  before do
    allow(Resque).to receive(:enqueue).and_return(true)
    session[:course_id] = course.id
  end

  context "as professor" do
    let(:professor) { create(:user) }

    before do
      CourseMembership.create!(user: professor, course: course, role: "professor")
      login_user(professor)
    end

    describe "GET index" do
      it "redirects to the dashboard path" do
        get :index
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  context "as student" do
    let(:student) { create(:user) }

    before do
      student.courses << course
      login_user(student)
    end

    describe "GET index" do
      it "redirects to the dashboard path" do
        get :index
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end
end
