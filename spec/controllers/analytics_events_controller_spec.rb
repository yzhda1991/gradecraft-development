describe AnalyticsEventsController, type: :controller do
  let(:course) { build(:course) }
  let(:user) { build(:user) }
  let(:student) { build(:user) }

  let(:event_session) {{
    course: course,
    user: user,
    student: student,
    request: request
  }}

  let(:event_session_with_params) { event_session.merge(params) }
  let(:params) {{ assignment: "40", score: "50", possible: "60" }}

  let(:event_logger) { logger_class.new }
  let(:enqueue_response) { double(:enqueue_response) }

  before do
    allow(user).to receive_messages(current_course: course)
    allow(controller).to receive_messages({
      current_user: user,
      event_session: event_session,
      require_course_membership: true,
      event_session_with_params: event_session_with_params
    })
  end

  describe "POST #predictor_event" do
    subject { post :predictor_event }

    before(:each) { allow(logger_class).to receive_messages(new: event_logger) }

    let(:logger_class) { PredictorEventLogger }

    context "a user is logged in and the request is for html" do
      it "should create a new PredictorEventLogger" do
        expect(logger_class).to receive(:new).with(event_session_with_params) { event_logger }
        subject
      end

      it "should enqueue the new PredictorEventLogger object with fallback" do
        expect(event_logger).to receive(:enqueue_with_fallback)
        subject
      end

      it "should not increment page views" do
        expect(controller).not_to receive(:increment_page_views)
        subject
      end

      it "should render nothing" do
        subject
        expect(response.body).to be_empty
      end

      it "should render an :ok response" do
        subject
        expect(response.status).to eq(200)
      end
    end
  end

  describe "POST #tab_select_event" do
    subject { post :tab_select_event }

    let(:logger_class) { PageviewEventLogger }
    let(:params) {{ url: "http://some.url", tab: "#great_tab" }}

    before { allow(controller).to receive(:params) { params } }
    before(:each) { allow(logger_class).to receive_messages(new: event_logger) }

    context "a user is logged in and the request is for html" do
      it "should create a new PredictorEventLogger" do
        expect(logger_class).to receive(:new).with(event_session_with_params) { event_logger }
        subject
      end

      it "should enqueue the new PredictorEventLogger object with fallback" do
        expect(event_logger).to receive(:build_page_from_params)
        subject
      end

      it "should not increment page views" do
        expect(controller).not_to receive(:increment_page_views)
        subject
      end

      it "should render nothing" do
        subject
        expect(response.body).to be_empty
      end

      it "should render an :ok response" do
        subject
        expect(response.status).to eq(200)
      end
    end
  end

  describe "#event_session_with_params" do
    subject { controller.instance_eval { event_session_with_params }}
    let(:params) {{ url: "http://some.url", tab: "#great_tab" }}
    before { allow(controller).to receive(:params) { params } }

    it "merges the params with the event session" do
      expect(subject).to eq(event_session.merge(params))
    end
  end
end
