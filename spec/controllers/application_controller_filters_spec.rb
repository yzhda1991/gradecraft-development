#spec/controllers/application_controller_spec.rb
require 'spec_helper'
require 'resque-scheduler'
require 'resque_spec/scheduler'

class ApplicationControllerFiltersTest < ApplicationController
  def html_page
    respond_to do |format|
      format.html { render text: "<div>page loaded</div>", response: 200 }
    end
  end

  def json_page
    respond_to do |format|
      format.json { render json: { waffles: ["blueberry", "strawberry"]}, response: 200 }
    end
  end
end

RSpec.describe ApplicationControllerFiltersTest, type: :controller do
  describe "#increment_page_views" do

    before do
      Rails.application.routes.draw do
        get '/html_page', to: 'application_controller_contrivance#html_page'
        get '/json_page', to: 'application_controller_contrivance#json_page'
        root to: 'application_controller_contrivance#html_page'
      end
    end

    before(:each) do
      allow(controller).to receive_messages(pageview_logger_attrs: pageview_logger_attrs_expectation)
    end

    # if current_user && request.format.html?
    context "no user is logged in" do
      it "should not increment the page views" do
        allow(controller).to receive_messages(current_user: nil)
        expect(PageviewEventLogger).not_to receive(:new).with pageview_logger_attrs_expectation
        get :html_page
      end
    end

    context "the request is not html" do
      it "should not increment the page views" do
        stub_current_user
        expect(PageviewEventLogger).not_to receive(:new).with pageview_logger_attrs_expectation
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
        expect(PageviewEventLogger).to receive(:new).with(pageview_logger_attrs_expectation) { @pageview_event_logger }
        get :html_page
      end

      it "should enqueue the new pageview logger in 2 hours" do
        expect(@pageview_event_logger).to receive(:enqueue_in).with(2.hours) { @enqueue_response }
        get :html_page
      end
    end

    after do
      Rails.application.reload_routes!
    end
  end

  def stub_current_user
    @current_user = double(:current_user).as_null_object
    allow(@current_user).to receive_messages(default_course: double(:default_course))
    allow(controller).to receive_messages(current_user: @current_user)
  end

  def pageview_logger_attrs_expectation
    {
      course_id: 50,
      user_id: 70,
      student_id: 90,
      user_role: "great role",
      page: "/a/great/path",
      created_at: Time.parse("Jan 20 1972")
    }
  end
end
