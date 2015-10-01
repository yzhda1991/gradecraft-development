#spec/controllers/application_controller_spec.rb
require 'spec_helper'
require 'resque-scheduler'
require 'resque_spec/scheduler'

RSpec.describe ApplicationController, type: :controller do
  describe "#increment_page_views" do
    # if current_user && request.format.html?
    context "no user is logged in" do
    end

    context "the request is not html" do
    end


    # if current_user && request.format.html?
    #   Resque.enqueue_in(ResqueManager.time_until_next_lull, PageviewEventLogger, 'pageview',
    #     course_id: current_course.try(:id),
    #     user_id: current_user.id,
    #     student_id: current_student.try(:id),
    #     user_role: current_user.role(current_course),
    #     page: request.original_fullpath,
    #     created_at: Time.now
    #   )
    # end
    context "a user is logged in and the request is formatted as html" do
      before(:each) do
        ResqueSpec.reset!
        @controller = ApplicationController.new
        stub_controller_for_pageview_logger
        stub_resque_manager
      end

      it "should schedule a pageview event" do
        @controller.instance_eval { increment_page_views }
        # expect(PageviewEventLogger).to have_scheduled('pageview', pageview_logger_attrs_expectation).in(2.hours)
        expect(PageviewEventLogger).to have_queued('pageview', pageview_logger_attrs_expectation)
      end
    end
  end

  def stub_resque_manager
    @resque_manager = double("ResqueManager")
    stub_const("ResqueManager", @resque_manager)
    allow(@resque_manager).to receive_messages(time_until_next_lull: 2.hours)
  end

  def stub_controller_for_pageview_logger
    # request_stub
    allow(@controller).to receive_message_chain(:request, :format, :html?) { true }

    # user and course doubles
    @current_course = double("Current Course")
    @current_user = double("Current User")
    allow(@controller).to receive(:current_course) { @current_course }
    allow(@controller).to receive(:current_user) { @current_user }

    # attr stubs
    allow(@current_course).to receive(:try).with(:id) { 50 }
    allow(@current_user).to receive_messages(id: 70)
    allow(@controller).to receive_message_chain(:current_student, :try).with(:id) { 90 }
    allow(@current_user).to receive(:role).with(@current_course) { "great role" }
    allow(@controller).to receive_message_chain(:request, :original_fullpath) { "/a/great/path" }
    allow(Time).to receive_messages(now: Time.parse("Jan 20 1972"))
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
