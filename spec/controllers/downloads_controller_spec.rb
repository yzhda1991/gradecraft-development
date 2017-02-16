require "spec_helper"

RSpec.describe DownloadsController, type: :controller do

  let(:course) { create :course }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:presenter) { double(:presenter).as_null_object }

  before do
    login_user(professor)
    allow(controller).to receive_messages \
      current_course: course,
      current_user: professor,
      presenter: presenter
  end

  describe "GET #index" do
    it "renders the index and injects the presenter locally" do
      get :index
      expect(response).to render_template(:index)
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
        expect(::Presenters::Downloads::Base).to receive(:new).with \
          params: controller.params,
          current_course: course,
          current_user: professor

        subject.instance_eval { presenter }
      end
    end
  end
end
