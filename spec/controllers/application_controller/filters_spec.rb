#spec/controllers/application_controller_spec.rb
require 'rails_spec_helper'
require 'resque-scheduler'
require 'resque_spec/scheduler'

# define routes for mapping #html_page and #json_page to the test controller
include Toolkits::Controllers::ApplicationControllerToolkit::Routes
include Toolkits::Controllers::ApplicationControllerToolkit::SharedExamples

RSpec.describe ApplicationControllerFiltersTest do
  include Toolkits::Controllers::ApplicationControllerToolkit::Filters

  before do
    define_filters_test_routes

  end

  describe "triggering pageview logger events" do
    let(:logger_attrs) { pageview_logger_attrs }
    before { allow(controller).to receive(:pageview_logger_attrs) { pageview_logger_attrs }}

    it_behaves_like "an EventLogger added to Resque with Mongo fallback", PageviewEventLogger
  end

  describe "trigger login logger events" do
    let(:course) { create(:course) }
    let(:user) { create(:user) }
    let(:logger_attrs) { login_logger_attrs }

    before do
      create :professor_course_membership, course: course, user: user
      allow(controller).to receive(:login_logger_attrs) { login_logger_attrs }
    end

    it_behaves_like "an EventLogger added to Resque with Mongo fallback", LoginEventLogger
  end

  after do
    # reload the proper routes to clear out custom /html_page and /json_page routes
    Rails.application.reload_routes!
  end
end
