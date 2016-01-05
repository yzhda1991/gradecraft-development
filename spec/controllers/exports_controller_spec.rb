require 'rails_spec_helper'

RSpec.describe ExportsController, type: :controller do

  let(:teams) { create_list(:team, 2) }
  let(:course) { create(:course, teams: teams) }
  let(:assignment_exports) { create_list(:assignment_export, 2, course: course) }
  let(:professor) { create(:professor_course_membership, course: course).user }

  before do
    login_user(professor)
    allow(controller).to receive(:current_course) { course }
  end

  describe "GET #index" do
    it "should get the relevant assignment exports" do
      get :index
      expect(assigns(:assignment_exports)).to eq(course.assignment_exports.order("updated_at DESC"))
    end

    it "should get the teams" do
      get :index
      expect(assigns(:teams)).to eq(course.teams)
    end
  end
end
