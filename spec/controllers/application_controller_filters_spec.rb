#spec/controllers/application_controller_spec.rb
require "rails_spec_helper"
require "resque-scheduler"
require "resque_spec/scheduler"

# pulls in the FiltersTest Class, which is a descendent of ApplicationController for test purposes
include Toolkits::Controllers::ApplicationController::TestClass

RSpec.describe FiltersTest, type: :controller do
  include Toolkits::Controllers::ApplicationController::Filters

  describe "#increment_page_views" do

    before do
      Rails.application.routes.draw do
        get "/html_page", to: "application_controller_filters_test#html_page"
        get "/json_page", to: "application_controller_filters_test#json_page"
        root to: "application_controller_filters_test#html_page"
      end
    end

    before(:each) do
      allow(controller).to receive_messages(pageview_logger_attrs: pageview_logger_attrs)
    end

    # if current_user && request.format.html?
    context "no user is logged in" do
      it "should not increment the page views" do
        allow(controller).to receive_messages(current_user: nil)
        expect(PageviewEventLogger).not_to receive(:new).with pageview_logger_attrs
        get :html_page
      end
    end

    context "the request is not html" do
      it "should not increment the page views" do
        stub_current_user
        expect(PageviewEventLogger).not_to receive(:new).with pageview_logger_attrs
        get :json_page, format: "json"
      end
    end

    context "a user is logged in and the request is formatted as html" do
      before(:each) do
        stub_current_user
        allow(controller).to receive_messages(time_until_next_lull: 2.hours)
        @pageview_event_logger = double(:pageview_event_logger)
        @enqueue_response = double(:enqueue_response)
        allow(@pageview_event_logger).to receive_messages(enqueue_in: @enqueue_response)
        allow(PageviewEventLogger).to receive_messages(new: @pageview_event_logger)
      end

      it "should create a new pageview logger" do
        expect(PageviewEventLogger).to receive(:new).with(pageview_logger_attrs) { @pageview_event_logger }
      end

      it "should enqueue the new pageview logger in 2 hours" do
        expect(@pageview_event_logger).to receive(:enqueue_in).with(2.hours) { @enqueue_response }
      end

      after(:each) do
        get :html_page
      end
    end

    context "Resque fails to reach Redis and returns a getaddrinfo socket error" do
      before do
        stub_current_user
        allow(PageviewEventLogger).to receive(:new).and_raise("Could not connect to Redis: getaddrinfo socket error.")
      end

      it "performs the pageview event log directly from the controller" do
        expect(PageviewEventLogger).to receive(:perform).with("pageview", pageview_logger_attrs)
        get :html_page
      end

      it "adds an additional pageview record to mongo" do
        expect { get :html_page }.to change{ Analytics::Event.count }.by(1)
      end
    end

    after do
      Rails.application.reload_routes!
    end
  end
end
