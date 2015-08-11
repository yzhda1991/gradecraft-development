require 'spec_helper'

describe AnnouncementsController do
  let(:course) { create :course }
  let(:professor) { create :user }

  before(:each) do
    professor.course_memberships << \
      CourseMembership.new(course_id: course.id, role: "professor")
    login_user(professor)
    session[:course_id] = course.id
  end

  describe "GET #index" do
    let!(:announcement) { create :announcement, course_id: course.id }
    let!(:non_course_announcement) { create :announcement }

    it "lists the announcements that are available for that course" do
      get :index
      expect(assigns(:announcements)).to eq [announcement]
    end
  end
end
