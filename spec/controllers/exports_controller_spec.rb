require 'rails_spec_helper'

RSpec.describe ExportsController, type: :controller do

  let(:teams) { create_list(:team, 2) }
  let(:course) { create(:course, teams: teams) }
  let(:submissions_exports) { create_list(:submissions_export, 2, course: course) }
  let(:professor) { create(:professor_course_membership, course: course).user }

  before do
    login_user(professor)
    allow(controller).to receive(:current_course) { course }
  end

  describe "GET #index" do
    it "should get the relevant submissions exports" do
      get :index
      expect(assigns(:submissions_exports)).to eq(course.submissions_exports.order("updated_at DESC"))
    end

    it "should get the teams" do
      get :index
      expect(assigns(:teams)).to eq(course.teams)
    end
  end
end
