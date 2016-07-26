require "rails_spec_helper"

RSpec.describe ExportsController, type: :controller do

  let(:course) { create :course }
  let(:professor) { create(:professor_course_membership, course: course).user }

  before do
    login_user(professor)
    allow(controller).to receive_messages \
      current_course: course,
      current_user: professor
  end

  describe "GET #index" do
    it "should get the relevant submissions exports" do
      get :index
      expect(assigns(:submissions_exports)).to eq(course.submissions_exports.order("updated_at DESC"))
    end
  end

  # let's test the presenter just to make sure that it builds and we don't
  # have any requirement or namespacing issues
  #
  describe "#presenter" do
    context "no @presenter has been built" do
      before(:each) do
        allow(controller).to receive(:presenter).and_call_original
        controller.instance_variable_set :@presenter, nil
      end

      it "builds a new presenter with the params, course and user" do
        expect(presenter_class).to receive(:new).with \
          params: controller.params,
          current_course: course,
          current_user: professor

        subject.instance_eval { presenter }
      end
    end
  end
end
