#spec/controllers/application_controller_spec.rb
require 'rails_spec_helper'
require 'resque-scheduler'
require 'resque_spec/scheduler'

# define routes for mapping #html_page and #json_page to the test controller
include Toolkits::Controllers::ApplicationControllerToolkit::Routes
include Toolkits::Controllers::ApplicationControllerToolkit::SharedExamples

RSpec.describe ApplicationControllerFiltersTest do
  include Toolkits::Controllers::ApplicationControllerToolkit::Filters

  let(:course) { build(:course) }
  let(:user) { build(:user) }
  let(:student) { build(:user) }

  let(:event_session) {{
    course: course,
    user: user,
    student: student,
    request: request
  }}

  before do
    define_filters_test_routes
    allow(controller).to receive(:event_session) { event_session }
  end

  describe "triggering pageview logger events" do
    subject { get :html_page }

    it_behaves_like "an EventLogger calling #enqueue_in_with_fallback", PageviewEventLogger

    context "the request is not html" do
      it "should not call #{described_class}" do
        stub_current_user
        expect(PageviewEventLogger).not_to receive(:new).with event_session
        get :json_page, format: "json"
      end
    end
  end

  describe "#record_course_login_event" do
    subject { controller.instance_eval { record_course_login_event }}

    before do
      create :professor_course_membership, course: course, user: user
    end

    it_behaves_like "an EventLogger calling #enqueue_in_with_fallback", LoginEventLogger

    context "the request is not html or xml" do
      let(:format) {{ html?: false, xml?: false, json?: true }}

      it "should not call #{described_class}" do
        stub_current_user
        allow(controller.request.format).to receive_messages(format)
        expect(PageviewEventLogger).not_to receive(:new).with event_session
        subject
      end
    end
  end

  after do
    # reload the proper routes to clear out custom /html_page and /json_page routes
    Rails.application.reload_routes!
  end
end
