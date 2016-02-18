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

  describe "#increment_page_views" do
    before do
      allow(controller).to receive_messages(pageview_logger_attrs: pageview_logger_attrs)
    end

    let(:logger_attrs) { pageview_logger_attrs }
    it_behaves_like "an EventLogger triggered by filter", PageviewEventLogger
  end

  after do
    # reload the proper routes to clear out custom /html_page and /json_page routes
    Rails.application.reload_routes!
  end
end
