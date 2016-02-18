#spec/controllers/application_controller_spec.rb
require 'rails_spec_helper'
require 'resque-scheduler'
require 'resque_spec/scheduler'

# define routes for mapping #html_page and #json_page to the test controller
include Toolkits::Controllers::ApplicationControllerToolkit::Routes
include Toolkits::Controllers::ApplicationControllerToolkit::SharedExamples

RSpec.describe ApplicationControllerFiltersTest do
  include Toolkits::Controllers::ApplicationControllerToolkit::Filters

  before { define_filters_test_routes }

  describe "triggering pageview logger events" do
    subject { get :html_page }

    let(:logger_attrs) { pageview_logger_attrs }

    before do
      allow(controller).to receive(:pageview_logger_attrs) { pageview_logger_attrs }
    end

    it_behaves_like "an EventLogger calling Resque with Mongo fallback", PageviewEventLogger

    context "the request is not html" do
      it "should not call #{described_class}" do
        stub_current_user
        expect(PageviewEventLogger).not_to receive(:new).with logger_attrs
        get :json_page, format: "json"
      end
    end
  end

  describe "#record_course_login_event" do
    subject { controller.instance_eval { record_course_login_event }}

    let(:course) { create(:course) }
    let(:user) { create(:user) }
    let(:logger_attrs) { login_logger_attrs }

    before do
      create :professor_course_membership, course: course, user: user
      allow(controller).to receive(:login_logger_attrs) { login_logger_attrs }
      allow(controller).to receive_message_chain(:request, :format, :html?) { true }
    end

    it_behaves_like "an EventLogger calling Resque with Mongo fallback", LoginEventLogger

    context "the request is not html or xml" do
      let(:format) {{ html?: false, xml?: false, json?: true }}

      it "should not call #{described_class}" do
        stub_current_user
        allow(controller.request.format).to receive_messages(format)
        expect(PageviewEventLogger).not_to receive(:new).with logger_attrs
        subject
      end
    end
  end

  after do
    # reload the proper routes to clear out custom /html_page and /json_page routes
    Rails.application.reload_routes!
  end
end
